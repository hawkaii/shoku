import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/cook_timer_repository.dart';
import 'package:food_finder/data/models/cook_timer.dart';
import 'package:food_finder/data/services/timer_alerts.dart';
import 'package:food_finder/presentation/state/cook_timer_providers.dart';

import 'support/fake_timer_alerts.dart';

/// The words the screen would pass in. The store only carries them to the alert.
const _copy = TimerAlertCopy(
  title: 'Timer is up',
  body: 'Step 3 is done — back to the kitchen.',
);

void main() {
  late AppDatabase db;
  final start = DateTime(2026, 1, 1, 19, 0);

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  /// A fresh store is what a relaunched app gets; the database is the only thing
  /// that survives, so every restoration test goes through a new one.
  Future<CookTimerStore> open() async {
    final store = CookTimerStore(CookTimerRepository(db));
    await pumpEventQueue();
    return store;
  }

  Future<CookTimerStore> openWithAlerts(FakeTimerAlerts alerts,
      {void Function(TimerAlertPermission)? onPermission}) async {
    final store = CookTimerStore(
      CookTimerRepository(db),
      alerts: alerts,
      onAlertPermission: onPermission,
    );
    await pumpEventQueue();
    return store;
  }

  test('a timer started before a kill comes back on the same step', () async {
    final before = await open();
    await before.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 2,
      duration: const Duration(minutes: 10),
      copy: _copy,
      now: start,
    );

    final after = await open();
    final timer = after.state;

    expect(timer, isNotNull);
    expect(timer!.stepIndex, 2);
    expect(timer.versionId, 'v1');
    expect(timer.dishId, 'd1');
    expect(timer.remainingMsAt(start.add(const Duration(minutes: 4))),
        6 * 60 * 1000);
  });

  test('a pause survives the app being killed', () async {
    final before = await open();
    await before.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 0,
      duration: const Duration(minutes: 10),
      copy: _copy,
      now: start,
    );
    await before.pause(now: start.add(const Duration(minutes: 1)));

    final after = await open();
    expect(after.state!.isPaused, isTrue);
    // Time spent paused is not time spent cooking.
    expect(after.state!.remainingMsAt(start.add(const Duration(minutes: 6))),
        9 * 60 * 1000);
  });

  test('resuming after a kill keeps the paused minutes out of the count',
      () async {
    final before = await open();
    await before.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 0,
      duration: const Duration(minutes: 10),
      copy: _copy,
      now: start,
    );
    await before.pause(now: start.add(const Duration(minutes: 1)));

    final after = await open();
    await after.resume(
      copy: _copy,
      now: start.add(const Duration(minutes: 5)),
    );

    expect(after.state!.isPaused, isFalse);
    expect(after.state!.remainingMsAt(start.add(const Duration(minutes: 6))),
        8 * 60 * 1000);
  });

  test('stop clears the row, and a relaunch finds nothing', () async {
    final before = await open();
    await before.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 1,
      duration: const Duration(minutes: 3),
      copy: _copy,
      now: start,
    );
    await before.stop();

    expect(before.state, isNull);
    final after = await open();
    expect(after.state, isNull);
  });

  test('a new version drops the timer instead of re-pointing it', () async {
    final store = await open();
    await store.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 4,
      duration: const Duration(minutes: 10),
      copy: _copy,
      now: start,
    );

    // Same version: the timer is still about the instruction on screen.
    expect(
      await store.dropIfVersionChanged(dishId: 'd1', versionId: 'v1'),
      isFalse,
    );
    expect(store.state, isNotNull);

    // Another dish's version is not this timer's business.
    expect(
      await store.dropIfVersionChanged(dishId: 'd2', versionId: 'v9'),
      isFalse,
    );
    expect(store.state, isNotNull);

    // The fork: step 4 now means something else, so the timer goes.
    expect(
      await store.dropIfVersionChanged(dishId: 'd1', versionId: 'v2'),
      isTrue,
    );
    expect(store.state, isNull);
  });

  test('an absurd length is stored as the longest timer we accept', () async {
    final store = await open();
    await store.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 0,
      duration: const Duration(days: 40),
      copy: _copy,
      now: start,
    );
    expect(store.state!.duration, CookTimer.maxDuration);

    await store.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 0,
      duration: Duration.zero,
      copy: _copy,
      now: start,
    );
    expect(store.state!.duration, CookTimer.minDuration);
  });

  test('starting again replaces the running timer', () async {
    final store = await open();
    await store.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 0,
      duration: const Duration(minutes: 2),
      copy: _copy,
      now: start,
    );
    await store.start(
      dishId: 'd1',
      versionId: 'v1',
      stepIndex: 3,
      duration: const Duration(minutes: 7),
      copy: _copy,
      now: start,
    );

    expect(store.state!.stepIndex, 3);
    expect(store.state!.remainingMsAt(start), 7 * 60 * 1000);
  });

  group('the alert that mirrors the timer', () {
    Future<CookTimerStore> started(FakeTimerAlerts alerts) async {
      final store = await openWithAlerts(alerts);
      await store.start(
        dishId: 'd1',
        versionId: 'v1',
        stepIndex: 2,
        duration: const Duration(minutes: 10),
        copy: _copy,
        now: start,
      );
      return store;
    }

    test('a start schedules one, by a stable id', () async {
      final alerts = FakeTimerAlerts();
      final store = await started(alerts);

      expect(alerts.scheduled, hasLength(1));
      expect(alerts.scheduledIds.single, store.state!.notificationId);
      expect(alerts.scheduledIds.single, CookTimer.notificationIdFor('v1', 2));
    });

    test('the id is derived from the version and the step', () {
      expect(CookTimer.notificationIdFor('v1', 2),
          CookTimer.notificationIdFor('v1', 2));
      expect(CookTimer.notificationIdFor('v1', 2),
          isNot(CookTimer.notificationIdFor('v1', 3)));
      expect(CookTimer.notificationIdFor('v1', 2),
          isNot(CookTimer.notificationIdFor('v2', 2)));
      expect(CookTimer.notificationIdFor('v1', 2), greaterThan(0));
    });

    test('pause cancels it, resume schedules it again', () async {
      final alerts = FakeTimerAlerts();
      final store = await started(alerts);

      await store.pause(now: start.add(const Duration(minutes: 1)));
      expect(alerts.cancelled, [store.state!.notificationId]);

      await store.resume(
        copy: _copy,
        now: start.add(const Duration(minutes: 2)),
      );
      expect(alerts.scheduled, hasLength(2));
    });

    test('stop cancels it', () async {
      final alerts = FakeTimerAlerts();
      final store = await started(alerts);
      final id = store.state!.notificationId;

      await store.stop();
      expect(alerts.cancelled.last, id);
    });

    test('a version fork cancels it', () async {
      final alerts = FakeTimerAlerts();
      final store = await started(alerts);

      final dropped = await store.dropIfVersionChanged(
        dishId: 'd1',
        versionId: 'v2',
      );

      expect(dropped, isTrue);
      expect(alerts.cancelled, isNotEmpty);
      expect(alerts.cancelled.last, CookTimer.notificationIdFor('v1', 2));
    });

    test('starting again cancels the old one before scheduling the new',
        () async {
      final alerts = FakeTimerAlerts();
      final store = await started(alerts);

      await store.start(
        dishId: 'd1',
        versionId: 'v1',
        stepIndex: 3,
        duration: const Duration(minutes: 2),
        copy: _copy,
        now: start,
      );

      expect(alerts.cancelled, [CookTimer.notificationIdFor('v1', 2)]);
      expect(alerts.scheduledIds.last, CookTimer.notificationIdFor('v1', 3));
    });

    test('exact permission schedules an exact alarm', () async {
      final alerts = FakeTimerAlerts();
      await started(alerts);
      expect(alerts.scheduledExact.single, isTrue);
    });

    test('refused exactness schedules an inexact one and says so', () async {
      final alerts = FakeTimerAlerts(permission: TimerAlertPermission.inexact);
      var reported = TimerAlertPermission.unknown;
      final store = await openWithAlerts(
        alerts,
        onPermission: (p) => reported = p,
      );
      await store.start(
        dishId: 'd1',
        versionId: 'v1',
        stepIndex: 0,
        duration: const Duration(minutes: 5),
        copy: _copy,
        now: start,
      );

      expect(alerts.scheduledExact.single, isFalse);
      expect(reported, TimerAlertPermission.inexact);
    });

    test('a denied permission schedules nothing and keeps the timer', () async {
      final alerts = FakeTimerAlerts(permission: TimerAlertPermission.denied);
      var reported = TimerAlertPermission.unknown;
      final store = await openWithAlerts(
        alerts,
        onPermission: (p) => reported = p,
      );
      await store.start(
        dishId: 'd1',
        versionId: 'v1',
        stepIndex: 0,
        duration: const Duration(minutes: 5),
        copy: _copy,
        now: start,
      );

      expect(alerts.scheduled, isEmpty);
      expect(reported, TimerAlertPermission.denied);
      expect(store.state, isNotNull, reason: 'the in-app timer still runs');
    });

    test('a timer that finishes in front of the cook cancels its alert',
        () async {
      final alerts = FakeTimerAlerts();
      final store = await started(alerts);

      await store.cancelAlert();

      expect(alerts.cancelled, contains(store.state!.notificationId));
      expect(store.state, isNotNull,
          reason: 'the card still says the timer is done');
    });

    test('the screen\'s words are what the notification says', () async {
      final alerts = FakeTimerAlerts();
      await started(alerts);

      expect(alerts.scheduledCopies.single.title, _copy.title);
      expect(alerts.scheduledCopies.single.body, _copy.body);
    });

    test('a schedule that fails is reported, and the timer keeps running',
        () async {
      final alerts = FakeTimerAlerts(scheduleSucceeds: false);
      var reported = TimerAlertPermission.unknown;
      final store = await openWithAlerts(
        alerts,
        onPermission: (p) => reported = p,
      );

      await store.start(
        dishId: 'd1',
        versionId: 'v1',
        stepIndex: 0,
        duration: const Duration(minutes: 5),
        copy: _copy,
        now: start,
      );

      expect(alerts.scheduled, isEmpty);
      expect(reported, TimerAlertPermission.unavailable,
          reason: 'a silent failure is the bug this ticket is about');
      expect(store.state, isNotNull);
      expect(store.state!.remainingMsAt(start), 5 * 60 * 1000);
    });
  });

  group('a permission that changed while the app was away', () {
    /// These timers start at the real clock: a refresh only re-arms a timer that
    /// has not already run out.
    Future<CookTimerStore> running(
      FakeTimerAlerts alerts, {
      void Function(TimerAlertPermission)? onPermission,
    }) async {
      final store = await openWithAlerts(alerts, onPermission: onPermission);
      await store.start(
        dishId: 'd1',
        versionId: 'v1',
        stepIndex: 2,
        duration: const Duration(minutes: 10),
        copy: _copy,
        now: DateTime.now(),
      );
      return store;
    }

    test('a grant made in Settings takes effect on resume, without a restart',
        () async {
      final alerts = FakeTimerAlerts(permission: TimerAlertPermission.inexact);
      var reported = TimerAlertPermission.unknown;
      final store = await running(alerts, onPermission: (p) => reported = p);
      expect(alerts.scheduledExact.single, isFalse);

      // The cook allowed exact alarms in Settings and came back.
      alerts.grant(TimerAlertPermission.allowed);
      await store.refreshAlertPermission();

      expect(reported, TimerAlertPermission.allowed);
      expect(alerts.scheduledExact.last, isTrue,
          reason: 'the queued alarm has to match what the card now claims');
      expect(alerts.permissionAsks, 1,
          reason: 'a resume reads the permission, it does not ask again');
    });

    test('a permission revoked while away cancels the queued alarm', () async {
      final alerts = FakeTimerAlerts();
      var reported = TimerAlertPermission.unknown;
      final store = await running(alerts, onPermission: (p) => reported = p);

      alerts.grant(TimerAlertPermission.denied);
      await store.refreshAlertPermission();

      expect(reported, TimerAlertPermission.denied);
      expect(alerts.cancelled, contains(store.state!.notificationId));
      expect(store.state, isNotNull, reason: 'the in-app timer still runs');
    });

    test('an unchanged permission is not re-scheduled', () async {
      final alerts = FakeTimerAlerts();
      final store = await running(alerts);

      await store.refreshAlertPermission();

      expect(alerts.permissionReads, 1);
      expect(alerts.scheduled, hasLength(1));
    });

    test('nothing is reported before the first timer has asked', () async {
      final alerts = FakeTimerAlerts(current: TimerAlertPermission.unknown);
      var reported = false;
      final store = await openWithAlerts(
        alerts,
        onPermission: (_) => reported = true,
      );

      await store.refreshAlertPermission();

      expect(reported, isFalse, reason: 'a guess painted on the card is noise');
    });
  });
}
