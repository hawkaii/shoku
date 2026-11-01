import 'dart:async';

import 'package:flutter/material.dart';

/// Motion system: tactile, fast, earned. Every action is acknowledged within
/// 100 ms; travel settles once; spectacle is reserved for milestones.
class ShokuMotion {
  static const push = Duration(milliseconds: 280);
  static const pop = Duration(milliseconds: 220);
  static const tab = Duration(milliseconds: 180);
  static const listItem = Duration(milliseconds: 240);
  static const stagger = Duration(milliseconds: 28);
  static const press = Duration(milliseconds: 80);
  static const release = Duration(milliseconds: 120);
  static const toggle = Duration(milliseconds: 180);
  static const numberRoll = Duration(milliseconds: 240);

  static const pushCurve = Curves.easeOutCubic;
  static const popCurve = Curves.easeInCubic;
  static const pressCurve = Curves.easeOutBack;

  const ShokuMotion._();
}

/// Page route: 6% horizontal travel + fade. Never a full-screen slide.
class ShokuPageRoute<T> extends PageRouteBuilder<T> {
  ShokuPageRoute({required Widget page, super.settings})
      : super(
          transitionDuration: ShokuMotion.push,
          reverseTransitionDuration: ShokuMotion.pop,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondary, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: ShokuMotion.pushCurve,
              reverseCurve: ShokuMotion.popCurve,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// 0.97 press with an ease-out-back release. Only used on tappable surfaces.
class ShokuPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool haptic;

  const ShokuPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.haptic = true,
  });

  @override
  State<ShokuPressable> createState() => _ShokuPressableState();
}

class _ShokuPressableState extends State<ShokuPressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down && !reduceMotion ? 0.97 : 1,
        duration: _down ? ShokuMotion.press : ShokuMotion.release,
        curve: _down ? ShokuMotion.pushCurve : ShokuMotion.pressCurve,
        child: widget.child,
      ),
    );
  }
}

/// Entrance: fade + 10px rise, staggered 28ms per index. First eight only.
class ShokuEntrance extends StatefulWidget {
  final Widget child;
  final int index;

  const ShokuEntrance({super.key, required this.child, this.index = 0});

  @override
  State<ShokuEntrance> createState() => _ShokuEntranceState();
}

class _ShokuEntranceState extends State<ShokuEntrance> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final delay = ShokuMotion.stagger * (widget.index.clamp(0, 7));
    // A Timer, not a bare delay: an item scrolled away or a list torn down must
    // not leave a rebuild scheduled behind it.
    _timer = Timer(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) return widget.child;
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.04),
      duration: ShokuMotion.listItem,
      curve: ShokuMotion.pushCurve,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: ShokuMotion.listItem,
        curve: ShokuMotion.pushCurve,
        child: widget.child,
      ),
    );
  }
}

/// Odometer roll for counters: old value up and out, new value up and in.
class ShokuNumberRoll extends StatelessWidget {
  final String value;
  final TextStyle style;

  const ShokuNumberRoll({super.key, required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSwitcher(
        duration: ShokuMotion.numberRoll,
        switchInCurve: ShokuMotion.pushCurve,
        switchOutCurve: ShokuMotion.popCurve,
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.8),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Text(value, key: ValueKey(value), style: style),
      ),
    );
  }
}
