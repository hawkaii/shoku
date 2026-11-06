import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/cook_timer.dart';

/// Whether a timer can ring with the phone in a pocket — and how punctually.
enum TimerAlertPermission {
  /// Nothing has been asked yet.
  unknown,

  /// Notifications allowed, exact alarms allowed: it rings on time.
  allowed,

  /// Notifications allowed, exact alarms refused: it rings late. Said out loud,
  /// because a cook trusting a punctual timer they do not have is worse than a
  /// cook who knows.
  inexact,

  /// The user said no. The in-app timer still works.
  denied,

  /// No notification support here (web), or the plugin failed. Quietly in-app.
  unavailable,
}

/// The words the notification says when the timer finishes.
///
/// Resolved by the screen, because the strings are localized and this layer has
/// no `BuildContext`. Passing them in from outside also keeps the notification in
/// the same language as the app instead of the hardcoded English it shipped with.
class TimerAlertCopy {
  const TimerAlertCopy({required this.title, required this.body});

  final String title;
  final String body;
}

/// Which family of permission rules this device follows.
enum TimerAlertsPlatform { android, ios, other }

/// The narrow slice of `FlutterLocalNotificationsPlugin` this service uses.
///
/// It exists so the decisions — which words, which schedule mode, what to do when
/// the platform refuses — can be tested without a method channel. The plugin is a
/// singleton whose platform implementations are singletons too, so a fake of the
/// plugin itself would mostly prove the fake's own plumbing. The production
/// implementation below is a pass-through, and it is the only code here that
/// touches the plugin.
abstract class TimerNotifications {
  TimerAlertsPlatform get platform;

  /// Initialises the plugin. False means "no notifications on this build".
  Future<bool> initialize();

  /// Android: whether the app may post notifications at all.
  Future<bool> notificationsEnabled();

  /// Android: the system prompt. True when the user allows notifications.
  Future<bool> requestNotifications();

  /// Android: whether alarms may fire at an exact minute.
  Future<bool> canScheduleExact();

  /// Android: opens the "alarms & reminders" settings page.
  Future<void> requestExactAlarms();

  /// iOS: the system prompt for alerts and sound.
  Future<bool> requestPermissions();

  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime at,
    required AndroidScheduleMode mode,
  });

  Future<void> cancel(int id);
}

/// The mirror of the in-app timer, for when the phone is not in the hand.
///
/// The in-app timer is the truth: it derives its remaining time from the wall
/// clock. This only rings at the moment that timer expects to reach zero, and is
/// cancelled by the same id whenever the timer ends. It is never a second clock.
abstract class TimerAlerts {
  /// Asks for permission — called at the first timer start, never at launch.
  Future<TimerAlertPermission> ensurePermission();

  /// Reads the current permission without asking anything.
  ///
  /// Called when the app comes back to the foreground: a grant made in Settings
  /// has to take effect now, not after a restart. It must never open a prompt.
  Future<TimerAlertPermission> currentPermission();

  /// Schedules the ring. False means it could not be scheduled, which the caller
  /// must say out loud rather than render as "alerts are on".
  Future<bool> schedule(
    CookTimer timer, {
    required bool exact,
    required TimerAlertCopy copy,
  });

  Future<void> cancel(CookTimer timer);
}

/// Used on web, and anywhere alerts are not wired: every call is a no-op, so the
/// timer behaves exactly as it did before this existed.
class SilentTimerAlerts implements TimerAlerts {
  const SilentTimerAlerts();

  @override
  Future<TimerAlertPermission> ensurePermission() async =>
      TimerAlertPermission.unavailable;

  @override
  Future<TimerAlertPermission> currentPermission() async =>
      TimerAlertPermission.unavailable;

  @override
  Future<bool> schedule(
    CookTimer timer, {
    required bool exact,
    required TimerAlertCopy copy,
  }) async =>
      false;

  @override
  Future<void> cancel(CookTimer timer) async {}
}

/// The real one, on Android and iOS.
class LocalTimerAlerts implements TimerAlerts {
  LocalTimerAlerts({TimerNotifications? notifications})
      : _notifications = notifications ?? _PluginNotifications();

  final TimerNotifications _notifications;

  static const _channelId = 'cook_timers';

  bool _ready = false;

  /// The exact-alarm prompt opens a system settings page, so it is asked at most
  /// once per process. The *answer* is never cached: it is re-read on every check
  /// so a grant made in Settings is believed without a restart.
  bool _askedForExact = false;

  Future<bool> _init() async {
    if (kIsWeb) return false;
    if (_ready) return true;

    // Scheduling is in absolute time, so the instant survives whatever zone the
    // device believes it is in.
    tzdata.initializeTimeZones();

    final initialised = await _notifications.initialize();
    _ready = true;
    return initialised;
  }

  @override
  Future<TimerAlertPermission> ensurePermission() async {
    if (kIsWeb) return TimerAlertPermission.unavailable;
    try {
      if (!await _init()) return TimerAlertPermission.unavailable;

      switch (_notifications.platform) {
        case TimerAlertsPlatform.android:
          final already = await _notifications.notificationsEnabled();
          final granted =
              already || await _notifications.requestNotifications();
          if (!granted) return TimerAlertPermission.denied;

          final current = await _androidPermission();
          if (current == TimerAlertPermission.allowed) return current;

          if (!_askedForExact) {
            _askedForExact = true;
            try {
              await _notifications.requestExactAlarms();
            } catch (_) {
              // No settings page on this build: inexact is the answer.
            }
          }
          return TimerAlertPermission.inexact;

        case TimerAlertsPlatform.ios:
          final granted = await _notifications.requestPermissions();
          return granted
              ? TimerAlertPermission.allowed
              : TimerAlertPermission.denied;

        case TimerAlertsPlatform.other:
          return TimerAlertPermission.allowed;
      }
    } catch (_) {
      // A notification problem is never allowed to break a cook.
      return TimerAlertPermission.unavailable;
    }
  }

  @override
  Future<TimerAlertPermission> currentPermission() async {
    if (kIsWeb) return TimerAlertPermission.unavailable;
    // Before the first timer the plugin has not been initialised, so nothing is
    // known yet and the card should say nothing. Initialising here would also
    // make "no prompts at launch" a lie on the first resume.
    if (!_ready) return TimerAlertPermission.unknown;
    try {
      switch (_notifications.platform) {
        case TimerAlertsPlatform.android:
          return await _androidPermission();
        case TimerAlertsPlatform.ios:
          final enabled = await _notifications.notificationsEnabled();
          return enabled
              ? TimerAlertPermission.allowed
              : TimerAlertPermission.denied;
        case TimerAlertsPlatform.other:
          return TimerAlertPermission.allowed;
      }
    } catch (_) {
      return TimerAlertPermission.unavailable;
    }
  }

  Future<TimerAlertPermission> _androidPermission() async {
    if (!await _notifications.notificationsEnabled()) {
      return TimerAlertPermission.denied;
    }
    return await _notifications.canScheduleExact()
        ? TimerAlertPermission.allowed
        : TimerAlertPermission.inexact;
  }

  @override
  Future<bool> schedule(
    CookTimer timer, {
    required bool exact,
    required TimerAlertCopy copy,
  }) async {
    if (kIsWeb) return false;
    try {
      if (!await _init()) return false;

      final now = DateTime.now();
      final remaining = timer.remainingMsAt(now);
      // Already finished: there is nothing to ring for, and that is not a
      // failure the card should report.
      if (remaining <= 0) return true;

      final end = now.add(Duration(milliseconds: remaining));

      await _notifications.zonedSchedule(
        id: timer.notificationId,
        title: copy.title,
        body: copy.body,
        at: tz.TZDateTime.from(end, tz.local),
        // Exactness is the difference between ringing at the minute the cook was
        // promised and ringing some minutes after it.
        mode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return true;
    } catch (_) {
      // The in-app timer is unaffected, so the cook is never harmed — but the
      // caller is told, so the card can stop pretending the alert will ring.
      return false;
    }
  }

  @override
  Future<void> cancel(CookTimer timer) async {
    if (kIsWeb) return;
    try {
      if (!await _init()) return;
      await _notifications.cancel(timer.notificationId);
    } catch (_) {
      // Nothing to do: a stale notification is better than a crash, and the
      // id is stable, so the next cancel will find it.
    }
  }
}

/// `LocalTimerAlerts`' only contact with `flutter_local_notifications`.
///
/// Everything here is a direct call: no decisions live in this class, which is why
/// it is not unit-tested — the rules it feeds are.
class _PluginNotifications implements TimerNotifications {
  _PluginNotifications({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  @override
  TimerAlertsPlatform get platform {
    if (kIsWeb) return TimerAlertsPlatform.other;
    if (_android != null) return TimerAlertsPlatform.android;
    if (_ios != null) return TimerAlertsPlatform.ios;
    return TimerAlertsPlatform.other;
  }

  @override
  Future<bool> initialize() async {
    final initialised = await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_timer'),
        // Permission is deliberately not requested here: this runs at launch,
        // and a notification prompt on first open is exactly the failure mode.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
    );
    return initialised ?? true;
  }

  @override
  Future<bool> notificationsEnabled() async {
    final android = _android;
    if (android != null) {
      final enabled = await android.areNotificationsEnabled();
      return enabled ?? false;
    }
    final ios = _ios;
    if (ios != null) {
      // Reading the status is not a prompt; the prompt is requestPermissions().
      return (await ios.checkPermissions())?.isEnabled ?? false;
    }
    return false;
  }

  @override
  Future<bool> requestNotifications() async =>
      await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<bool> canScheduleExact() async =>
      await _android?.canScheduleExactNotifications() ?? false;

  @override
  Future<void> requestExactAlarms() async {
    await _android?.requestExactAlarmsPermission();
  }

  @override
  Future<bool> requestPermissions() async =>
      await _ios?.requestPermissions(alert: true, sound: true) ?? false;

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime at,
    required AndroidScheduleMode mode,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: at,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          LocalTimerAlerts._channelId,
          'Cook timers',
          channelDescription: 'Rings when a cook-mode timer finishes.',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
      ),
      androidScheduleMode: mode,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }
}
