import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../data/mock/journal_data.dart';
import '../../state/journal_providers.dart';
import '../../state/journal_store.dart';
import '../../widgets/kit/dish_image.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/mic_field.dart';
import '../../widgets/kit/motion.dart';

Future<void> showDebriefSheet(
  BuildContext context, {
  required Dish dish,
  List<String> changes = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => DebriefSheet(dish: dish, initialChanges: changes),
  );
}

/// The commit point: photo, rating, mood, what was missing, and the diff
/// against the original. One version per cook, decided here.
class DebriefSheet extends ConsumerStatefulWidget {
  final Dish dish;
  final List<String> initialChanges;

  const DebriefSheet({super.key, required this.dish, this.initialChanges = const []});

  @override
  ConsumerState<DebriefSheet> createState() => _DebriefSheetState();
}

class _DebriefSheetState extends ConsumerState<DebriefSheet> {
  late final List<String> _changes = [...widget.initialChanges];
  final _note = TextEditingController();
  final _changeField = TextEditingController();
  int _rating = 4;
  CookMood _mood = CookMood.comfort;
  File? _photo;

  @override
  void dispose() {
    _note.dispose();
    _changeField.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _photo = File(picked.path));
    }
  }

  void _save() {
    ref.read(journalStoreProvider.notifier).commitCook(
          dishId: widget.dish.id,
          mood: _mood,
          rating: _rating,
          note: _note.text.trim(),
          changes: _changes,
          photoUrl: _photo?.path,
        );
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved as v${widget.dish.versions.length + 1} · ${_mood.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final nextVersion = widget.dish.versions.length + 1;
    final kcalDelta = _changes.length * 18;
    final proteinDelta = _changes.length * 2;

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
            Text('How did it go?', style: ShokuType.h1.copyWith(color: c.ink)),
            const SizedBox(height: 2),
            Text(
              '${widget.dish.title} · becomes v$nextVersion',
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: ShokuSpace.lg),

            // Photo
            GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  ShokuDishImage(
                    url: _photo?.path ?? widget.dish.coverUrl,
                    title: widget.dish.title,
                    height: 140,
                    radius: ShokuRadius.card,
                  ),
                  Positioned(
                    right: ShokuSpace.sm,
                    bottom: ShokuSpace.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.canvas.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.photo_camera_outlined, size: 13, color: c.ink),
                          const SizedBox(width: 5),
                          Text(_photo == null ? 'ADD PHOTO' : 'CHANGE PHOTO',
                              style: ShokuType.label.copyWith(fontSize: 9, color: c.ink)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ShokuSpace.lg),

            // Rating
            Row(
              children: [
                ShokuLabel('rating'),
                const Spacer(),
                for (var i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _rating = i);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        i <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 22,
                        color: i <= _rating ? c.reward : c.inkMuted,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: ShokuSpace.md),

            // Mood
            ShokuLabel('what kind of cook was it'),
            const SizedBox(height: ShokuSpace.sm),
            Row(
              children: [
                for (final mood in CookMood.values) ...[
                  Expanded(
                    child: ShokuPressable(
                      onTap: () => setState(() => _mood = mood),
                      child: AnimatedContainer(
                        duration: ShokuMotion.toggle,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _mood == mood ? c.ink : c.surface,
                          borderRadius: BorderRadius.circular(ShokuRadius.chip),
                          border: Border.all(color: _mood == mood ? c.ink : c.hairline),
                        ),
                        child: Center(
                          child: Text(
                            mood.name.toUpperCase(),
                            style: ShokuType.label.copyWith(
                              fontSize: 9.5,
                              color: _mood == mood ? c.canvas : c.inkMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (mood != CookMood.values.last) const SizedBox(width: ShokuSpace.sm),
                ],
              ],
            ),
            const SizedBox(height: ShokuSpace.lg),

            // Changes
            ShokuLabel('what altered from the original'),
            const SizedBox(height: ShokuSpace.sm),
            if (_changes.isEmpty)
              Text(
                'Nothing yet — add what you did differently.',
                style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final change in _changes)
                    ShokuChip(change, color: c.reward, icon: Icons.bolt),
                ],
              ),
            const SizedBox(height: ShokuSpace.sm),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      border: Border.all(color: c.hairline),
                    ),
                    child: TextField(
                      controller: _changeField,
                      style: ShokuType.bodySmall.copyWith(color: c.ink),
                      cursorColor: c.accent,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'e.g. 2 tbsp honey instead of 3',
                        hintStyle: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isEmpty) return;
                        setState(() {
                          _changes.add(value.trim());
                          _changeField.clear();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: ShokuSpace.sm),
                ShokuPressable(
                  onTap: () {
                    if (_changeField.text.trim().isEmpty) return;
                    setState(() {
                      _changes.add(_changeField.text.trim());
                      _changeField.clear();
                    });
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      border: Border.all(color: c.hairline),
                    ),
                    child: Icon(Icons.add, size: 17, color: c.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ShokuSpace.lg),

            const SizedBox(height: ShokuSpace.md),

            // Note
            ShokuLabel('what was missing'),
            const SizedBox(height: ShokuSpace.sm),
            MicField(controller: _note, hint: '“needed more acid, next time add lime”'),
            const SizedBox(height: ShokuSpace.lg),

            ShokuPressable(
              onTap: _save,
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
                    _changes.isEmpty ? 'Save as v$nextVersion' : 'Save & upgrade to v$nextVersion',
                    style: ShokuType.title.copyWith(color: c.onAccent, fontSize: 14),
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
