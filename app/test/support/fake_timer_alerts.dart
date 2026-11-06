import 'package:food_finder/data/models/cook_timer.dart';
import 'package:food_finder/data/services/timer_alerts.dart';

/// Records what the mirror was asked to do. The notification itself can only be
/// seen on a device; what can be proven here is that every path that starts a
/// timer schedules one, every path that ends one cancels it by the same id, and
/// every failure is reported instead of rendered as success.
class FakeTimerAlerts implements TimerAlerts {
  FakeTimerAlerts({
    this.permission = TimerAlertPermission.allowed,
    this.current,
    this.scheduleSucceeds = true,
  });

  /// What asking for permission returns.
  TimerAlertPermission permission;

  /// What reading it without asking returns. Null means "same as [permission]".
  TimerAlertPermission? current;

  /// False makes [schedule] report that it could not create the alarm.
  bool scheduleSucceeds;

  final List<CookTimer> scheduled = [];
  final List<bool> scheduledExact = [];
  final List<TimerAlertCopy> scheduledCopies = [];
  final List<int> cancelled = [];
  final List<int> scheduledIds = [];
  int permissionAsks = 0;
  int permissionReads = 0;

  /// What a foregrounded app would find, when it differs from what asking gave.
  void grant(TimerAlertPermission permission) => current = permission;

  @override
  Future<TimerAlertPermission> ensurePermission() async {
    permissionAsks++;
    return permission;
  }

  @override
  Future<TimerAlertPermission> currentPermission() async {
    permissionReads++;
    return current ?? permission;
  }

  @override
  Future<bool> schedule(
    CookTimer timer, {
    required bool exact,
    required TimerAlertCopy copy,
  }) async {
    if (!scheduleSucceeds) return false;
    scheduled.add(timer);
    scheduledExact.add(exact);
    scheduledCopies.add(copy);
    scheduledIds.add(timer.notificationId);
    return true;
  }

  @override
  Future<void> cancel(CookTimer timer) async {
    cancelled.add(timer.notificationId);
  }
}
