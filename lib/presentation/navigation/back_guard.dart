import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/kit/exit_dialog.dart';
import 'app_router.dart';

/// App-level back handling. A shell-level PopScope does not always receive the
/// system back button once go_router owns the router, so this listens at the
/// binding instead: pop the current route if there is one, otherwise ask before
/// leaving the app.
class ShokuBackGuard extends StatefulWidget {
  final Widget child;
  const ShokuBackGuard({super.key, required this.child});

  @override
  State<ShokuBackGuard> createState() => _ShokuBackGuardState();
}

class _ShokuBackGuardState extends State<ShokuBackGuard> with WidgetsBindingObserver {
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return false;

    // A pushed screen (dish, cook, help) owns its own back behaviour.
    if (navigator.canPop()) return false;

    if (_dialogOpen) return true;
    _dialogOpen = true;

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      _dialogOpen = false;
      return false;
    }

    final leave = await showExitDialog(context);
    _dialogOpen = false;

    if (leave) {
      await SystemNavigator.pop();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
