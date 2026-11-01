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

/// The mirror of the in-app timer, for when the phone is not in the hand.
///
/// The in-app timer is the truth: it derives its remaining time from the wall
/// clock. This only rings at the moment that timer expects to reach zero, and is
/// cancelled by the same id whenever the timer ends. It is never a second clock.
abstract class TimerAlerts {
  /// Asks for permission — called at the first timer start, never at launch.
  Future<TimerAlertPermission> ensurePermission();

  Future<void> schedule(CookTimer timer, {required bool exact});

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
  Future<void> schedule(CookTimer timer, {required bool exact}) async {}

  @override
  Future<void> cancel(CookTimer timer) async {}
}

/// The real one, on Android and iOS.
class LocalTimerAlerts implements TimerAlerts {
  LocalTimerAlerts({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'cook_timers';

  bool _ready = false;
  bool _askedForExact = false;

  Future<bool> _init() async {
    if (kIsWeb) return false;
    if (_ready) return true;

    // Scheduling is in absolute time, so the instant survives whatever zone the
    // device believes it is in.
    tzdata.initializeTimeZones();

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
    _ready = true;
    return initialised ?? true;
  }

  @override
  Future<TimerAlertPermission> ensurePermission() async {
    if (kIsWeb) return TimerAlertPermission.unavailable;
    try {
      if (!await _init()) return TimerAlertPermission.unavailable;

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final already = await android.areNotificationsEnabled() ?? false;
        final granted =
            already || (await android.requestNotificationsPermission() ?? false);
        if (!granted) return TimerAlertPermission.denied;

        final exact = await android.canScheduleExactNotifications() ?? false;
        if (exact) return TimerAlertPermission.allowed;

        // Asking opens a system settings page, so it is asked once per launch
        // and the answer is only known on the next timer start.
        if (!_askedForExact) {
          _askedForExact = true;
          try {
            await android.requestExactAlarmsPermission();
          } catch (_) {
            // No settings page on this build: inexact is the answer.
          }
        }
        return TimerAlertPermission.inexact;
      }

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
              alert: true,
              sound: true,
            ) ??
            false;
        return granted
            ? TimerAlertPermission.allowed
            : TimerAlertPermission.denied;
      }

      return TimerAlertPermission.allowed;
    } catch (_) {
      // A notification problem is never allowed to break a cook.
      return TimerAlertPermission.unavailable;
    }
  }

  @override
  Future<void> schedule(CookTimer timer, {required bool exact}) async {
    if (kIsWeb) return;
    try {
      if (!await _init()) return;

      final now = DateTime.now();
      final remaining = timer.remainingMsAt(now);
      if (remaining <= 0) return; // already done: nothing to ring for

      final end = now.add(Duration(milliseconds: remaining));

      await _plugin.zonedSchedule(
        id: timer.notificationId,
        title: 'Timer is up',
        body: 'Step ${timer.stepIndex + 1} is done — back to the kitchen.',
        scheduledDate: tz.TZDateTime.from(end, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Cook timers',
            channelDescription: 'Rings when a cook-mode timer finishes.',
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.alarm,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // The in-app timer is unaffected, so this failure stays quiet.
    }
  }

  @override
  Future<void> cancel(CookTimer timer) async {
    if (kIsWeb) return;
    try {
      if (!await _init()) return;
      await _plugin.cancel(id: timer.notificationId);
    } catch (_) {
      // Nothing to do: a stale notification is better than a crash, and the
      // id is stable, so the next cancel will find it.
    }
  }
}
