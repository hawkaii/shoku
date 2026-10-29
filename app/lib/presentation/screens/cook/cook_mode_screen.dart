import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../../widgets/kit/step_library.dart';
import '../../widgets/kit/step_text.dart';
import '../assistant/assistant_sheet.dart';
import '../log/debrief_sheet.dart';

/// Step-by-step cook mode: one step, one instructive loop, one floating AI.
/// Swipeable, so it works with a knuckle when your hands are busy.
class CookModeScreen extends ConsumerStatefulWidget {
  final String dishId;
  const CookModeScreen({super.key, required this.dishId});

  @override
  ConsumerState<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends ConsumerState<CookModeScreen> {
  final _pages = PageController();
  int _step = 0;
  final _changes = <String>[];
  int? _secondsLeft;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  void _startTimer(int minutes) {
    _timer?.cancel();
    setState(() => _secondsLeft = minutes * 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if ((_secondsLeft ?? 0) <= 1) {
          t.cancel();
          _secondsLeft = 0;
          HapticFeedback.mediumImpact();
        } else {
          _secondsLeft = (_secondsLeft ?? 1) - 1;
        }
      });
    });
  }

  String get _clock {
    final s = _secondsLeft ?? 0;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
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
    final steps = dish.steps.isEmpty ? const ['Follow the recipe.'] : dish.steps;
    final isLast = _step == steps.length - 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _confirmLeave() && mounted) Navigator.of(context).pop();
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
              ShokuHairline(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: ShokuSpace.lg, vertical: ShokuSpace.sm),
                child: ShokuProgress(value: (_step + 1) / steps.length),
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
                        setState(() {
                          _step = i;
                          _timer?.cancel();
                          _secondsLeft = null;
                        });
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
                            const SizedBox(height: ShokuSpace.lg),
                            if (i == _step && _secondsLeft != null)
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: c.accent,
                                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                                      border:
                                          Border.all(color: c.ink, width: ShokuStroke.brutal),
                                      boxShadow: [
                                        BoxShadow(
                                            color: c.ink,
                                            offset: ShokuStroke.brutalShadow,
                                            blurRadius: 0),
                                      ],
                                    ),
                                    child: Text(_clock,
                                        style: ShokuType.stat.copyWith(
                                            fontSize: 15, color: c.onAccent)),
                                  ),
                                  const SizedBox(width: ShokuSpace.sm),
                                  Text('running',
                                      style: ShokuType.label.copyWith(color: c.inkMuted)),
                                ],
                              )
                            else if (_hasTime(steps[i]))
                              GestureDetector(
                                onTap: () => _startTimer(_minutesIn(steps[i])),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: c.surface,
                                    borderRadius: BorderRadius.circular(ShokuRadius.chip),
                                    border: Border.all(color: c.hairline),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.timer_outlined, size: 15, color: c.ink),
                                      const SizedBox(width: 6),
                                      Text('start ${_minutesIn(steps[i])} min timer',
                                          style: ShokuType.label.copyWith(color: c.ink)),
                                    ],
                                  ),
                                ),
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
