import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../../data/models/cook_timer.dart';
import '../../state/cook_timer_providers.dart';
import '../../state/journal_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/step_library.dart';
import '../../widgets/kit/step_text.dart';
import '../assistant/assistant_sheet.dart';
import '../log/debrief_sheet.dart';
import 'timer_card.dart';

/// Step-by-step cook mode: one step, one instructive loop, one floating AI.
/// Swipeable, so it works with a knuckle when your hands are busy.
class CookModeScreen extends ConsumerStatefulWidget {
  final String dishId;
  const CookModeScreen({super.key, required this.dishId});

  @override
  ConsumerState<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends ConsumerState<CookModeScreen>
    with WidgetsBindingObserver {
  final _pages = PageController();
  int _step = 0;
  final _changes = <String>[];

  /// A repaint pulse, not a countdown. The number on screen comes from the wall
  /// clock every time this fires, so a missed or late tick costs a frame, never a
  /// second.
  Timer? _ticker;
  bool _rang = false;
  bool _adoptedTimer = false;
  bool _dropScheduled = false;
  bool _timerCleared = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // The row is read asynchronously; the screen adopts it once it has been
    // restored, which is how a killed app comes back to the right step.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _pages.dispose();
    super.dispose();
  }

  /// Coming back from the background: recompute from the clock on the first
  /// visible frame rather than up to a second later.
  ///
  /// Nothing alerts while the app was away — there is no local notification and
  /// no exact-alarm permission. If the timer ran out with the screen off, this
  /// is the moment the cook finds out.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) _pulse();
  }

  /// Keeps at most one ticker alive, and only while there is something to watch.
  void _ensureTicker(bool running) {
    if (running && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _pulse());
    } else if (!running) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  void _pulse() {
    if (!mounted) return;
    final timer = ref.read(cookTimerProvider);
    if (timer != null &&
        !_rang &&
        !timer.isPaused &&
        timer.isDoneAt(DateTime.now())) {
      // Haptic only, and only because this screen is awake. A locked phone gets
      // no alert: there is no local notification and no exact-alarm permission.
      _rang = true;
      HapticFeedback.mediumImpact();
    }
    setState(() {});
  }

  void _startTimer(Dish dish, String versionId, int minutes) {
    _rang = false;
    _timerCleared = false;
    ref.read(cookTimerProvider.notifier).start(
          dishId: dish.id,
          versionId: versionId,
          stepIndex: _step,
          duration: Duration(minutes: minutes),
        );
  }

  /// A timer that survived a kill belongs to a step, so reopening the screen
  /// lands there rather than at step one with a clock running for no visible
  /// reason.
  void _adoptRestoredTimer(
    CookTimerStore store,
    CookTimer? timer,
    int stepCount,
  ) {
    if (_adoptedTimer || !store.isRestored) return;
    _adoptedTimer = true;
    if (timer == null || timer.stepIndex == _step || timer.stepIndex >= stepCount) {
      return;
    }
    final page = timer.stepIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pages.hasClients) return;
      _pages.jumpToPage(page);
      setState(() => _step = page);
    });
  }

  /// A fork replaces the version the timer was started on. Its step index now
  /// points at a different instruction, so the timer is dropped and said out
  /// loud instead of quietly inheriting somebody else's step.
  void _dropStaleTimer(CookTimer? timer, String dishId, String versionId) {
    if (timer == null || timer.versionId == versionId || _dropScheduled) return;
    _dropScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final dropped = await ref
          .read(cookTimerProvider.notifier)
          .dropIfVersionChanged(dishId: dishId, versionId: versionId);
      _dropScheduled = false;
      if (dropped && mounted) setState(() => _timerCleared = true);
    });
  }

  Future<bool> _confirmLeave() async {
    if (_changes.isEmpty && _step == 0) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) {
        final c = context.colors;
        return Dialog(
          backgroundColor: c.canvas,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShokuRadius.card),
            side: BorderSide(color: c.ink, width: ShokuStroke.brutal),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ShokuSpace.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leave this cook?', style: ShokuType.h1.copyWith(color: c.ink)),
                const SizedBox(height: ShokuSpace.xs),
                Text(
                  _changes.isEmpty
                      ? 'You are part-way through. Nothing is saved yet.'
                      : '${_changes.length} change${_changes.length == 1 ? '' : 's'} in this cook will be discarded.',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: ShokuSpace.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ShokuRadius.chip),
                            side: BorderSide(color: c.hairline),
                          ),
                        ),
                        child: Text('Keep cooking',
                            style: ShokuType.title.copyWith(color: c.ink, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.sm),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          backgroundColor: c.ink,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ShokuRadius.chip),
                          ),
                        ),
                        child: Text('Discard',
                            style: ShokuType.title.copyWith(color: c.canvas, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return leave ?? false;
  }

  Future<void> _addChange() async {
    final controller = TextEditingController();
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.canvas,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          ShokuSpace.lg,
          ShokuSpace.lg,
          ShokuSpace.lg,
          MediaQuery.of(context).viewInsets.bottom + ShokuSpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What did you change?',
                style: ShokuType.h2.copyWith(color: context.colors.ink)),
            const SizedBox(height: ShokuSpace.sm),
            TextField(
              controller: controller,
              autofocus: true,
              style: ShokuType.body.copyWith(color: context.colors.ink),
              decoration: InputDecoration(
                hintText: 'more lime, 2 minutes less, air-fried instead',
                hintStyle: ShokuType.bodySmall.copyWith(color: context.colors.inkMuted),
              ),
            ),
            const SizedBox(height: ShokuSpace.lg),
            ShokuPressable(
              onTap: () => Navigator.of(context).pop(controller.text.trim()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: ShokuGradients.crimsonPress,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                  border: Border.all(color: context.colors.ink, width: ShokuStroke.brutal),
                ),
                child: Center(
                  child: Text('Add to this cook',
                      style: ShokuType.title
                          .copyWith(color: context.colors.onAccent, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (value != null && value.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() => _changes.add(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dish = ref.watch(dishProvider(widget.dishId));
    if (dish == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final steps = dish.steps.isEmpty ? const ['Follow the recipe.'] : dish.steps;
    final isLast = _step == steps.length - 1;

    final versionId = dish.versions.isEmpty ? '' : dish.versions.last.id;
    final timer = ref.watch(cookTimerProvider);
    final store = ref.read(cookTimerProvider.notifier);
    final timerForThisDish = timer != null && timer.dishId == dish.id ? timer : null;
    final remainingMs = timerForThisDish?.remainingMsAt(DateTime.now()) ?? 0;

    _adoptRestoredTimer(store, timerForThisDish, steps.length);
    _dropStaleTimer(timerForThisDish, dish.id, versionId);
    _ensureTicker(
      timerForThisDish != null && !timerForThisDish.isPaused && remainingMs > 0,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmLeave()) navigator.pop();
      },
      child: Scaffold(
        backgroundColor: c.canvas,
        body: SafeArea(
          child: Column(
            children: [
              // ---- top bar ------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(ShokuSpace.lg, ShokuSpace.sm, ShokuSpace.lg, 0),
                child: Row(
                  children: [
                    ShokuPressable(
                      onTap: () async {
                        if (await _confirmLeave() && context.mounted) Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(ShokuRadius.chip),
                          border: Border.all(color: c.hairline),
                        ),
                        child: Icon(Icons.close, size: 17, color: c.ink),
                      ),
                    ),
                    const SizedBox(width: ShokuSpace.md),
                    Expanded(
                      child: Text(
                        dish.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ShokuType.title.copyWith(color: c.ink, fontSize: 14),
                      ),
                    ),
                    if (_changes.isNotEmpty) ...[
                      ShokuChip('${_changes.length} changed', color: c.reward, filled: true),
                      const SizedBox(width: ShokuSpace.sm),
                    ],
                    Text(
                      '${_step + 1}/${steps.length}',
                      style: ShokuType.stat.copyWith(fontSize: 12, color: c.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ShokuSpace.md),
              const ShokuHairline(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: ShokuSpace.lg, vertical: ShokuSpace.sm),
                child: ShokuProgress(value: (_step + 1) / steps.length),
              ),

              // ---- the timer ------------------------------------------------
              if (timerForThisDish != null || _hasTime(steps[_step]))
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      ShokuSpace.lg, 0, ShokuSpace.lg, ShokuSpace.sm),
                  child: CookTimerCard(
                    timer: timerForThisDish,
                    currentStep: _step,
                    remainingMs: remainingMs,
                    suggestedMinutes:
                        _hasTime(steps[_step]) ? _minutesIn(steps[_step]) : 0,
                    onStart: () => _startTimer(dish, versionId, _minutesIn(steps[_step])),
                    onPause: () => ref.read(cookTimerProvider.notifier).pause(),
                    onResume: () => ref.read(cookTimerProvider.notifier).resume(),
                    onStop: () => ref.read(cookTimerProvider.notifier).stop(),
                  ),
                ),
              if (_timerCleared && timerForThisDish == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      ShokuSpace.lg, 0, ShokuSpace.lg, ShokuSpace.sm),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Timer cleared — this dish has a new version',
                      style: ShokuType.label.copyWith(color: c.inkMuted),
                    ),
                  ),
                ),

              // ---- swipeable steps + floating AI ---------------------------
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pages,
                      itemCount: steps.length,
                      onPageChanged: (i) {
                        HapticFeedback.selectionClick();
                        setState(() => _step = i);
                      },
                      itemBuilder: (context, i) => SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          ShokuSpace.lg,
                          0,
                          ShokuSpace.lg,
                          ShokuSpace.xxxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StepMotionLibrary.build(context, steps[i], height: 168),
                            const SizedBox(height: ShokuSpace.lg),
                            ShokuLabel('step ${(i + 1).toString().padLeft(2, '0')}'),
                            const SizedBox(height: ShokuSpace.sm),
                            StepText(
                              text: steps[i],
                              fontSize: 26,
                              ingredients: dish.versions.last.ingredients,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: ShokuSpace.lg,
                      bottom: ShokuSpace.md,
                      child: _AiFab(
                        onTap: () => showAssistantSheet(
                          context,
                          dish: dish,
                          onLogChange: _addChange,
                        ),
                        badge: _changes.isEmpty ? null : '${_changes.length}',
                      ),
                    ),
                  ],
                ),
              ),

              // ---- navigation ---------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(ShokuSpace.lg, 0, ShokuSpace.lg, ShokuSpace.lg),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: ShokuPressable(
                          onTap: () => _pages.previousPage(
                            duration: ShokuMotion.push,
                            curve: ShokuMotion.pushCurve,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(ShokuRadius.chip),
                              border: Border.all(color: c.hairline),
                            ),
                            child: Center(
                              child: Text('Back',
                                  style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: ShokuSpace.sm),
                    Expanded(
                      flex: 2,
                      child: ShokuPressable(
                        onTap: () {
                          if (!isLast) {
                            _pages.nextPage(
                              duration: ShokuMotion.push,
                              curve: ShokuMotion.pushCurve,
                            );
                          } else {
                            showDebriefSheet(context, dish: dish, changes: _changes);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            gradient: ShokuGradients.crimsonPress,
                            borderRadius: BorderRadius.circular(ShokuRadius.chip),
                            border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                            boxShadow: [
                              BoxShadow(
                                  color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isLast ? 'Finish & log' : 'Next step',
                              style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasTime(String step) =>
      RegExp(r'(\d+)\s*(min|minute)', caseSensitive: false).hasMatch(step);

  int _minutesIn(String step) {
    final match = RegExp(r'(\d+)\s*(min|minute)', caseSensitive: false).firstMatch(step);
    return int.tryParse(match?.group(1) ?? '5') ?? 5;
  }
}

class _AiFab extends StatelessWidget {
  final VoidCallback onTap;
  final String? badge;

  const _AiFab({required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ShokuPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: ShokuGradients.crimsonPress,
          borderRadius: BorderRadius.circular(ShokuRadius.pill),
          border: Border.all(color: c.ink, width: ShokuStroke.brutal),
          boxShadow: [
            BoxShadow(color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 15, color: c.onAccent),
            const SizedBox(width: 6),
            Text('Ask', style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 13)),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: c.onAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(badge!,
                    style: ShokuType.stat.copyWith(fontSize: 9, color: c.accent)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
