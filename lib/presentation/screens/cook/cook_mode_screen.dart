import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';
import '../log/debrief_sheet.dart';

/// Step-by-step cook mode: one step, one timer, one draft bar. Nothing else.
class CookModeScreen extends ConsumerStatefulWidget {
  final String dishId;
  const CookModeScreen({super.key, required this.dishId});

  @override
  ConsumerState<CookModeScreen> createState() => _CookModeScreenState();
}

class _CookModeScreenState extends ConsumerState<CookModeScreen> {
  int _step = 0;
  final _changes = <String>[];
  int? _secondsLeft;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
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

  Future<void> _addChange(Dish dish) async {
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
            Text('What did you change?', style: ShokuType.h2.copyWith(color: context.colors.ink)),
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
                      style: ShokuType.title.copyWith(color: context.colors.onAccent, fontSize: 14)),
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

    return Scaffold(
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
                    onTap: () => Navigator.of(context).pop(),
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
                  Text(
                    '${_step + 1} / ${steps.length}',
                    style: ShokuType.stat.copyWith(fontSize: 12, color: c.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ShokuSpace.md),
            ShokuHairline(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.lg, vertical: ShokuSpace.sm),
              child: ShokuProgress(value: (_step + 1) / steps.length),
            ),

            // ---- the step ----------------------------------------------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShokuLabel('step ${(_step + 1).toString().padLeft(2, '0')}'),
                    const SizedBox(height: ShokuSpace.sm),
                    Text(
                      steps[_step],
                      style: ShokuType.h1.copyWith(color: c.ink, fontSize: 28, height: 1.25),
                    ),
                    if (_secondsLeft != null) ...[
                      const SizedBox(height: ShokuSpace.lg),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: c.accent,
                              borderRadius: BorderRadius.circular(ShokuRadius.chip),
                              border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                              boxShadow: [
                                BoxShadow(
                                    color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
                              ],
                            ),
                            child: Text(
                              _clock,
                              style: ShokuType.stat.copyWith(fontSize: 15, color: c.onAccent),
                            ),
                          ),
                          const SizedBox(width: ShokuSpace.sm),
                          Text('running',
                              style: ShokuType.label.copyWith(color: c.inkMuted)),
                        ],
                      ),
                    ] else if (_stepHasTime(steps[_step])) ...[
                      const SizedBox(height: ShokuSpace.lg),
                      GestureDetector(
                        onTap: () => _startTimer(_minutesIn(steps[_step])),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              Text(
                                'start ${_minutesIn(steps[_step])} min timer',
                                style: ShokuType.label.copyWith(color: c.ink),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ---- draft bar ----------------------------------------------
            if (_changes.isNotEmpty || true)
              Padding(
                padding: const EdgeInsets.fromLTRB(ShokuSpace.lg, 0, ShokuSpace.lg, ShokuSpace.sm),
                child: ShokuPressable(
                  onTap: () => _addChange(dish),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      border: Border.all(color: c.hairline),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bolt, size: 15, color: c.reward),
                        const SizedBox(width: 6),
                        Text(
                          _changes.isEmpty
                              ? 'Changed something? Add it to this cook'
                              : '${_changes.length} change${_changes.length == 1 ? '' : 's'} in this cook',
                          style: ShokuType.bodySmall.copyWith(color: c.ink),
                        ),
                        const Spacer(),
                        Icon(Icons.add, size: 15, color: c.inkMuted),
                      ],
                    ),
                  ),
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
                        onTap: () => setState(() => _step--),
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
                          HapticFeedback.selectionClick();
                          setState(() => _step++);
                        } else {
                          showDebriefSheet(
                            context,
                            dish: dish,
                            changes: _changes,
                          );
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
    );
  }

  bool _stepHasTime(String step) => RegExp(r'(\d+)\s*(min|minute)', caseSensitive: false).hasMatch(step);

  int _minutesIn(String step) {
    final match = RegExp(r'(\d+)\s*(min|minute)', caseSensitive: false).firstMatch(step);
    return int.tryParse(match?.group(1) ?? '5') ?? 5;
  }
}
