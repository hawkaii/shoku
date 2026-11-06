import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/models/cook_timer.dart';
import 'package:food_finder/data/services/timer_alerts.dart';
import 'package:food_finder/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;

/// The plugin itself is a singleton whose platform implementations read method
/// channels; a fake of it would prove the fake's plumbing, not these rules. So the
/// seam is [TimerNotifications], and this records exactly what the service asked
/// the platform to do.
class _FakeNotifications implements TimerNotifications {
  _FakeNotifications({
    this.platform = TimerAlertsPlatform.android,
    this.notificationsAllowed = true,
    this.grantOnRequest = true,
  });

  @override
  TimerAlertsPlatform platform;

  bool notificationsAllowed;
  bool exactAllowed = true;

  /// Whether the system prompt is answered with "yes".
  bool grantOnRequest;

  bool initialised = true;
  bool throwOnSchedule = false;
  bool throwOnCancel = false;

  int initialiseCalls = 0;
  int notificationRequests = 0;
  int exactRequests = 0;
  int permissionPrompts = 0;

  final List<_Scheduled> scheduled = [];
  final List<int> cancelled = [];

  @override
  Future<bool> initialize() async {
    initialiseCalls++;
    return initialised;
  }

  @override
  Future<bool> notificationsEnabled() async => notificationsAllowed;

  @override
  Future<bool> requestNotifications() async {
    notificationRequests++;
    if (grantOnRequest) notificationsAllowed = true;
    return notificationsAllowed;
  }

  @override
  Future<bool> canScheduleExact() async => exactAllowed;

  @override
  Future<void> requestExactAlarms() async => exactRequests++;

  @override
  Future<bool> requestPermissions() async {
    permissionPrompts++;
    return notificationsAllowed;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime at,
    required AndroidScheduleMode mode,
  }) async {
    if (throwOnSchedule) throw StateError('the platform refused the alarm');
    scheduled
        .add(_Scheduled(id: id, title: title, body: body, at: at, mode: mode));
  }

  @override
  Future<void> cancel(int id) async {
    if (throwOnCancel) throw StateError('the platform refused the cancel');
    cancelled.add(id);
  }
}

class _Scheduled {
  const _Scheduled({
    required this.id,
    required this.title,
    required this.body,
    required this.at,
    required this.mode,
  });

  final int id;
  final String title;
  final String body;
  final tz.TZDateTime at;
  final AndroidScheduleMode mode;
}

CookTimer _timer({int stepIndex = 2}) => CookTimer(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: stepIndex,
      startedAt: DateTime.now(),
      duration: const Duration(minutes: 10),
    );

void main() {
  late AppLocalizations hi;

  setUpAll(() async {
    // Not English on purpose: English is the string the hardcoded version used, so
    // only a translation proves the copy really comes from the screen.
    hi = await AppLocalizations.delegate.load(const Locale('hi'));
  });

  TimerAlertCopy copyOf() => TimerAlertCopy(
        title: hi.timerNotificationTitle,
        body: hi.timerNotificationBody(3),
      );

  group('schedule', () {
    test('sends the localized title and body, under the timer\'s own id',
        () async {
      final notifications = _FakeNotifications();
      final alerts = LocalTimerAlerts(notifications: notifications);
      final timer = _timer();

      expect(await alerts.schedule(timer, exact: true, copy: copyOf()), isTrue);

      final sent = notifications.scheduled.single;
      expect(sent.title, hi.timerNotificationTitle);
      expect(sent.title, isNot('Timer is up'),
          reason: 'the English string is what the hardcoded version said');
      expect(sent.body, hi.timerNotificationBody(3));
      expect(sent.body, contains('3'));
      expect(sent.id, timer.notificationId);
      expect(sent.id, CookTimer.notificationIdFor('v1', 2));
    });

    test('an exact timer is scheduled as exactAllowWhileIdle', () async {
      final notifications = _FakeNotifications();
      final alerts = LocalTimerAlerts(notifications: notifications);

      await alerts.schedule(_timer(), exact: true, copy: copyOf());

      expect(notifications.scheduled.single.mode,
          AndroidScheduleMode.exactAllowWhileIdle);
    });

    test('a timer without exactness is scheduled as inexactAllowWhileIdle',
        () async {
      final notifications = _FakeNotifications();
      final alerts = LocalTimerAlerts(notifications: notifications);

      await alerts.schedule(_timer(), exact: false, copy: copyOf());

      expect(notifications.scheduled.single.mode,
          AndroidScheduleMode.inexactAllowWhileIdle);
    });

    test('it rings at the moment the in-app clock reaches zero', () async {
      final notifications = _FakeNotifications();
      final alerts = LocalTimerAlerts(notifications: notifications);
      final timer = _timer();
      final expected = DateTime.now().add(timer.duration);

      await alerts.schedule(timer, exact: true, copy: copyOf());

      // A second of slack: the service computes the remainder from the wall
      // clock, and both are read at slightly different instants.
      final delta = notifications.scheduled.single.at
          .difference(expected)
          .inMilliseconds
          .abs();
      expect(delta, lessThan(1000));
    });

    test('a plugin that throws returns false instead of ringing nothing',
        () async {
      final notifications = _FakeNotifications()..throwOnSchedule = true;
      final alerts = LocalTimerAlerts(notifications: notifications);

      // The store turns this false into TimerAlertPermission.unavailable, which
      // the card renders; see cook_timer_store_test.dart for that half.
      expect(await alerts.schedule(_timer(), exact: true, copy: copyOf()),
          isFalse);
    });

    test('a plugin that will not initialise returns false', () async {
      final notifications = _FakeNotifications()..initialised = false;
      final alerts = LocalTimerAlerts(notifications: notifications);

      expect(await alerts.schedule(_timer(), exact: true, copy: copyOf()),
          isFalse);
      expect(notifications.scheduled, isEmpty);
    });

    test('a timer that already finished schedules nothing and is not a failure',
        () async {
      final notifications = _FakeNotifications();
      final alerts = LocalTimerAlerts(notifications: notifications);
      final finished = CookTimer(
        dishId: 'd1',
        versionId: 'v1',
        stepIndex: 2,
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        duration: const Duration(minutes: 10),
      );

      expect(
          await alerts.schedule(finished, exact: true, copy: copyOf()), isTrue);
      expect(notifications.scheduled, isEmpty);
    });
  });

  group('cancel', () {
    test('cancels by the timer\'s stable notification id', () async {
      final notifications = _FakeNotifications();
      final alerts = LocalTimerAlerts(notifications: notifications);
      final timer = _timer();

      await alerts.cancel(timer);

      expect(
          notifications.cancelled.single, CookTimer.notificationIdFor('v1', 2));
    });

    test('two steps of one version are two different alarms', () async {
      final notifications = _FakeNotifications();
      final alerts = LocalTimerAlerts(notifications: notifications);

      await alerts.cancel(_timer(stepIndex: 2));
      await alerts.cancel(_timer(stepIndex: 3));

      expect(notifications.cancelled, [
        CookTimer.notificationIdFor('v1', 2),
        CookTimer.notificationIdFor('v1', 3),
      ]);
    });

    test('a plugin that throws does not take the app down with it', () async {
      final notifications = _FakeNotifications()..throwOnCancel = true;
      final alerts = LocalTimerAlerts(notifications: notifications);

      await alerts.cancel(_timer());

      expect(notifications.cancelled, isEmpty);
    });
  });

  group('permission', () {
    test('asking for an exact alarm opens the settings page once per process',
        () async {
      final notifications = _FakeNotifications()..exactAllowed = false;
      final alerts = LocalTimerAlerts(notifications: notifications);

      expect(await alerts.ensurePermission(), TimerAlertPermission.inexact);
      expect(notifications.exactRequests, 1);

      expect(await alerts.ensurePermission(), TimerAlertPermission.inexact);
      expect(notifications.exactRequests, 1,
          reason: 'a settings page on every timer start would be a nightmare');
    });

    test('a grant made in Settings is believed without a restart', () async {
      final notifications = _FakeNotifications()..exactAllowed = false;
      final alerts = LocalTimerAlerts(notifications: notifications);
      expect(await alerts.ensurePermission(), TimerAlertPermission.inexact);

      // The cook comes back from Settings having allowed exact alarms.
      notifications.exactAllowed = true;

      expect(await alerts.currentPermission(), TimerAlertPermission.allowed);
      expect(notifications.exactRequests, 1,
          reason: 'reading the answer must not open another settings page');
    });

    test('reading the permission never prompts for notifications either',
        () async {
      final notifications = _FakeNotifications();
      final alerts = LocalTimerAlerts(notifications: notifications);
      await alerts.ensurePermission();
      notifications.notificationRequests = 0;
      notifications.permissionPrompts = 0;

      await alerts.currentPermission();

      expect(notifications.notificationRequests, 0);
      expect(notifications.permissionPrompts, 0);
    });

    test('before the first timer the plugin is left alone', () async {
      final notifications = _FakeNotifications();
      final alerts = LocalTimerAlerts(notifications: notifications);

      // A resume at launch must not prompt for anything.
      expect(await alerts.currentPermission(), TimerAlertPermission.unknown);
      expect(notifications.initialiseCalls, 0);
    });

    test('notifications refused is denied, and the timer is still the cook\'s',
        () async {
      final notifications = _FakeNotifications(
        notificationsAllowed: false,
        grantOnRequest: false,
      );
      final alerts = LocalTimerAlerts(notifications: notifications);

      expect(await alerts.ensurePermission(), TimerAlertPermission.denied);
    });

    test('iOS answers the prompt with whether alerts were granted', () async {
      final notifications = _FakeNotifications(
        platform: TimerAlertsPlatform.ios,
        notificationsAllowed: false,
      );
      final alerts = LocalTimerAlerts(notifications: notifications);

      expect(await alerts.ensurePermission(), TimerAlertPermission.denied);
      expect(notifications.permissionPrompts, 1);
    });
  });
}
