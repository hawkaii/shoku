import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/labels.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/photo_service.dart';
import '../../../data/mock/journal_data.dart';
import '../../../data/models/pantry_item.dart';
import '../../state/journal_store.dart';
import '../../state/pantry_providers.dart';
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
  bool _saving = false;

  /// Pantry lines the cook confirmed as used, and the amount they edited.
  final _usage = <String, double>{};
  final _checked = <String>{};
  List<PantryItem>? _undoSnapshot;
  int _skipped = 0;

  /// Rows whose default has already been applied, so a rebuild never re-checks
  /// something the cook unchecked.
  final _defaulted = <String>{};

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

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // The photo is uploaded first and stored as a key; a path on this phone is
    // not a URL and must never be written as one.
    String? photoKey;
    String? photoUrl;
    if (_photo != null) {
      try {
        final uploaded = await PhotoService(
          api: ApiClient(),
        ).upload(_photo!, role: 'debrief');
        photoKey = uploaded.key;
        photoUrl = uploaded.url;
      } catch (_) {
        photoKey = null;
        photoUrl = null;
      }
    }

    try {
      final version = await ref.read(journalStoreProvider.notifier).commitCook(
            dishId: widget.dish.id,
            mood: _mood,
            rating: _rating,
            note: _note.text.trim(),
            changes: _changes,
            photoUrl: photoUrl,
            photoKey: photoKey,
          );
      HapticFeedback.mediumImpact();
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(version == null
              ? l10n.debriefSaveFailed
              : l10n.debriefSaved(version, moodLabel(l10n, _mood))),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.debriefSaveFailed)));
    }
  }

  /// Pantry items the user has aliases (or a name) for, in this dish's lines.
  /// Nothing is inferred: an item with no confirmed match is not offered.
  List<PantryItem> _matched(List<PantryItem> pantry) {
    final lines = (widget.dish.versions.isEmpty
            ? widget.dish.steps
            : widget.dish.versions.last.ingredients)
        .map((l) => l.toLowerCase())
        .toList();
    return pantry
        .where((p) => p.quantity != null && p.unit != null)
        .where((p) =>
            lines.any((l) => l.contains(p.name.toLowerCase())) ||
            p.aliases.any((a) =>
                a.trim().isNotEmpty && lines.any((l) => l.contains(a.toLowerCase()))))
        .toList();
  }

  /// The recipe line that mentions this item, first match wins.
  String? _lineFor(PantryItem item, List<String> lines) {
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains(item.name.toLowerCase())) return line;
      for (final alias in item.aliases) {
        if (alias.trim().isNotEmpty && lower.contains(alias.toLowerCase())) {
          return line;
        }
      }
    }
    return null;
  }

  static String _formatAmount(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

  Future<void> _deduct(List<PantryItem> matched) async {
    // A row with no confirmed amount is not a deduction.
    final chosen = matched
        .where((p) => _checked.contains(p.id) && _usage[p.id] != null)
        .toList();
    if (chosen.isEmpty) return;
    final store = ref.read(pantryStoreProvider.notifier);
    _undoSnapshot = [for (final item in chosen) item];
    final skipped = await store.deduct([
      for (final item in chosen)
        (
          item: item,
          amount: _usage[item.id] ?? item.quantity!,
          unit: item.unit!,
        ),
    ]);
    if (!mounted) return;
    setState(() {
      _skipped = skipped;
      _checked.clear();
    });
  }

  Future<void> _undo() async {
    final snapshot = _undoSnapshot;
    if (snapshot == null) return;
    final store = ref.read(pantryStoreProvider.notifier);
    for (final item in snapshot) {
      await store.save(item);
    }
    if (!mounted) return;
    setState(() {
      _undoSnapshot = null;
      _skipped = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final nextVersion = widget.dish.versions.length + 1;
    final matched = _matched(ref.watch(pantryStoreProvider));
    final rawLines = widget.dish.versions.isEmpty
        ? widget.dish.steps
        : widget.dish.versions.last.ingredients;
    for (final item in matched) {
      if (!_defaulted.add(item.id)) continue;
      // Default to what the recipe line states — never to the whole stock.
      final line = _lineFor(item, rawLines);
      final stated = line == null
          ? null
          : PantryParser.statedAmountIn(line: line, stockUnit: item.unit!);
      if (stated == null) {
        _checked.remove(item.id);
        _usage.remove(item.id);
      } else {
        _usage[item.id] = stated;
        _checked.add(item.id);
      }
    }

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
            Text(l10n.debriefTitle, style: ShokuType.h1.copyWith(color: c.ink)),
            const SizedBox(height: 2),
            Text(
              l10n.debriefSubtitle(widget.dish.title, nextVersion),
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
                          Text(
                              _photo == null
                                  ? l10n.debriefAddPhoto
                                  : l10n.debriefChangePhoto,
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
                ShokuLabel(l10n.debriefRating),
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
            ShokuLabel(l10n.debriefMoodLabel),
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
                            moodLabel(l10n, mood).toUpperCase(),
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
            ShokuLabel(l10n.debriefChangesLabel),
            const SizedBox(height: ShokuSpace.sm),
            if (_changes.isEmpty)
              Text(
                l10n.debriefNoChanges,
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
                        hintText: l10n.debriefChangeHint,
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
            ShokuLabel(l10n.debriefNoteLabel),
            const SizedBox(height: ShokuSpace.sm),
            MicField(controller: _note, hint: l10n.debriefNoteHint),

            if (matched.isNotEmpty) ...[
              const SizedBox(height: ShokuSpace.lg),
              ShokuLabel(l10n.debriefPantryLabel),
              const SizedBox(height: ShokuSpace.sm),
              for (final item in matched)
                Row(
                  children: [
                    Checkbox(
                      value: _checked.contains(item.id),
                      onChanged: (value) => setState(() {
                        if (value == true) {
                          _checked.add(item.id);
                        } else {
                          _checked.remove(item.id);
                        }
                      }),
                    ),
                    Expanded(
                      child: Text(item.name,
                          style: ShokuType.bodySmall.copyWith(color: c.ink)),
                    ),
                    SizedBox(
                      width: 72,
                      child: TextFormField(
                        key: ValueKey('deduct-${item.id}'),
                        initialValue: _usage[item.id] == null
                            ? ''
                            : _formatAmount(_usage[item.id]!),
                        keyboardType: TextInputType.number,
                        // The stock is a hint, never a value: a line that
                        // states no amount must not default to all of it.
                        decoration: InputDecoration(
                          hintText: _formatAmount(item.quantity!),
                          hintStyle: ShokuType.bodySmall.copyWith(
                              color: c.inkMuted.withValues(alpha: 0.6)),
                        ),
                        onChanged: (value) {
                          final parsed = double.tryParse(value);
                          setState(() {
                            if (parsed == null || parsed <= 0) {
                              _usage.remove(item.id);
                            } else {
                              _usage[item.id] = parsed;
                            }
                          });
                        },
                        style: ShokuType.bodySmall.copyWith(color: c.ink),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(unitLabel(l10n, item.unit!),
                        style: ShokuType.label.copyWith(color: c.inkMuted)),
                  ],
                ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      key: const ValueKey('deduct-matches'),
                      onPressed:
                          _checked.isEmpty ? null : () => _deduct(matched),
                      child: Text(l10n.debriefDeduct),
                    ),
                  ),
                  if (_undoSnapshot != null)
                    TextButton(
                      key: const ValueKey('deduct-undo'),
                      onPressed: _undo,
                      child: Text(l10n.chatUndo),
                    ),
                ],
              ),
              if (_skipped > 0)
                Text(l10n.debriefSkipped(_skipped),
                    key: const ValueKey('deduct-skipped'),
                    style: ShokuType.label.copyWith(color: c.inkMuted)),
            ],

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
                    _changes.isEmpty
                        ? l10n.debriefSave(nextVersion)
                        : l10n.debriefSaveUpgrade(nextVersion),
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
