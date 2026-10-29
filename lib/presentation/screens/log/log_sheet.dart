import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/motion.dart';

Future<void> showLogSheet(BuildContext context, Dish dish) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => LogSheet(dish: dish),
  );
}

/// Delta-first logging: photo, outcome, one line of changes. Thirty seconds,
/// never a full recipe edit.
class LogSheet extends ConsumerStatefulWidget {
  final Dish dish;
  const LogSheet({super.key, required this.dish});

  @override
  ConsumerState<LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends ConsumerState<LogSheet> {
  CookOutcome? _outcome;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSave => _outcome != null;

  void _save() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged as v${widget.dish.currentVersion + 1} · ${_outcome!.label}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final changes = _controller.text
        .split(RegExp(r'[,;\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: ShokuSpace.lg,
        right: ShokuSpace.lg,
        top: ShokuSpace.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + ShokuSpace.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: ShokuSpace.lg),
                decoration: BoxDecoration(
                  color: c.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Log tonight’s cook', style: ShokuType.h1.copyWith(color: c.ink)),
            const SizedBox(height: 2),
            Text(
              widget.dish.title,
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: ShokuSpace.lg),

            // Photo slot
            GestureDetector(
              onTap: () => HapticFeedback.selectionClick(),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(ShokuRadius.card),
                  border: Border.all(color: c.hairline),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(ShokuRadius.card),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ShokuDishImage(
                        url: widget.dish.coverUrl,
                        title: widget.dish.title,
                        radius: ShokuRadius.card,
                      ),
                      Container(color: c.ink.withValues(alpha: 0.18)),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_camera_outlined, color: c.canvas, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              'SNAP TONIGHT’S RESULT',
                              style: ShokuType.label.copyWith(color: c.canvas, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: ShokuSpace.lg),

            ShokuLabel('how did it go'),
            const SizedBox(height: ShokuSpace.sm),
            Row(
              children: [
                for (final outcome in CookOutcome.values) ...[
                  Expanded(
                    child: ShokuPressable(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _outcome = outcome);
                      },
                      child: AnimatedContainer(
                        duration: ShokuMotion.toggle,
                        curve: ShokuMotion.pushCurve,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _outcome == outcome
                              ? (outcome == CookOutcome.nailedIt ? c.ready : c.surfaceAlt)
                              : c.surface,
                          borderRadius: BorderRadius.circular(ShokuRadius.chip),
                          border: Border.all(
                            color: _outcome == outcome ? c.ink : c.hairline,
                            width: _outcome == outcome ? ShokuStroke.brutal : ShokuStroke.hairline,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            outcome.upper,
                            style: ShokuType.label.copyWith(
                              fontSize: 9.5,
                              color: _outcome == outcome && outcome == CookOutcome.nailedIt
                                  ? c.canvas
                                  : c.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (outcome != CookOutcome.values.last) const SizedBox(width: ShokuSpace.sm),
                ],
              ],
            ),
            const SizedBox(height: ShokuSpace.lg),

            ShokuLabel('what did you change'),
            const SizedBox(height: ShokuSpace.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md, vertical: 4),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.hairline),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                style: ShokuType.bodySmall.copyWith(color: c.ink),
                cursorColor: c.accent,
                maxLines: 2,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'More lime, 2 minutes less, air-fried instead',
                  hintStyle: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ),
            ),
            if (changes.isNotEmpty) ...[
              const SizedBox(height: ShokuSpace.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final change in changes.take(4))
                    ShokuChip(change, color: c.reward, icon: Icons.bolt),
                ],
              ),
            ],
            const SizedBox(height: ShokuSpace.lg),
            ShokuPressable(
              onTap: _canSave ? _save : null,
              child: AnimatedOpacity(
                duration: ShokuMotion.toggle,
                opacity: _canSave ? 1 : 0.45,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: ShokuGradients.crimsonPress,
                    borderRadius: BorderRadius.circular(ShokuRadius.chip),
                    border: Border.all(color: c.ink, width: ShokuStroke.brutal),
                    boxShadow: [
                      BoxShadow(color: c.ink, offset: ShokuStroke.brutalShadow, blurRadius: 0),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      changes.isEmpty
                          ? 'Save as v${widget.dish.currentVersion}'
                          : 'Save & upgrade to v${widget.dish.currentVersion + 1}',
                      style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
