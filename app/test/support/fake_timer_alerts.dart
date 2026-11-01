import 'package:food_finder/data/models/cook_timer.dart';
import 'package:food_finder/data/services/timer_alerts.dart';

/// Records what the mirror was asked to do. The notification itself can only be
/// seen on a device; what can be proven here is that every path that starts a
/// timer schedules one, and every path that ends one cancels it by the same id.
class FakeTimerAlerts implements TimerAlerts {
  FakeTimerAlerts({this.permission = TimerAlertPermission.allowed});

  TimerAlertPermission permission;

  final List<CookTimer> scheduled = [];
  final List<bool> scheduledExact = [];
  final List<int> cancelled = [];
  final List<int> scheduledIds = [];
  int permissionAsks = 0;

  @override
  Future<TimerAlertPermission> ensurePermission() async {
    permissionAsks++;
    return permission;
  }

  @override
  Future<void> schedule(CookTimer timer, {required bool exact}) async {
    scheduled.add(timer);
    scheduledExact.add(exact);
    scheduledIds.add(timer.notificationId);
  }

  @override
  Future<void> cancel(CookTimer timer) async {
    cancelled.add(timer.notificationId);
  }
}
