import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/labels.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/failure_log.dart';
import '../../../data/mock/journal_data.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/photo_service.dart';
import '../../state/journal_store.dart';
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
  bool _saving = false;
  File? _photo;
  final _controller = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _note.dispose();
    super.dispose();
  }

  List<String> get _changes => _controller.text
      .split(RegExp(r'[,;\n]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  /// Locked only when there is nothing to record. A note alone is a log; so is
  /// a photo, so is one change.
  bool get _canSave =>
      _outcome != null ||
      _changes.isNotEmpty ||
      _note.text.trim().isNotEmpty ||
      _photo != null;

  Future<void> _pickPhoto() async {
    HapticFeedback.selectionClick();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      imageQuality: 85,
    );
    if (picked != null && mounted) setState(() => _photo = File(picked.path));
  }

  Future<void> _save() async {
    if (_saving || !_canSave) return;
    setState(() => _saving = true);

    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final changes = _changes;
    final rating = switch (_outcome) {
      CookOutcome.nailedIt => 5,
      CookOutcome.good => 4,
      CookOutcome.needsWork => 2,
      null => 3,
    };

    // The photo goes to the bucket directly, then travels as a row. A path on
    // this phone is never a URL and must never be stored as one.
    String? photoKey;
    String? photoUrl;
    if (_photo != null) {
      try {
        final uploaded = await PhotoService(
          api: ApiClient(),
        ).upload(_photo!, role: 'debrief');
        photoKey = uploaded.key;
        photoUrl = uploaded.url;
      } catch (error, stack) {
        // The cook still saves; only the photo is missing from the entry.
        logFailure('log sheet photo upload', error, stack);
        photoKey = null;
        photoUrl = null;
      }
    }

    try {
      final version = await ref.read(journalStoreProvider.notifier).commitCook(
            dishId: widget.dish.id,
            mood: CookMood.comfort,
            rating: rating,
            note: _note.text.trim(),
            changes: changes,
            photoUrl: photoUrl,
            photoKey: photoKey,
          );
      HapticFeedback.mediumImpact();
      navigator.pop();
      final outcome = _outcome;
      messenger.showSnackBar(
        SnackBar(
          content: Text(version == null
              ? l10n.logSaveFailed
              : outcome == null
                  ? l10n.logSaved(version)
                  : l10n.logSavedWithOutcome(
                      version, outcomeLabel(l10n, outcome))),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error, stack) {
      // The user already sees `logSaveFailed`; the line says which throw it was.
      logFailure('log sheet save', error, stack);
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.logSaveFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final changes = _changes;

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
            Text(l10n.logTitle, style: ShokuType.h1.copyWith(color: c.ink)),
            const SizedBox(height: 2),
            Text(
              widget.dish.title,
              style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
            ),
            const SizedBox(height: ShokuSpace.lg),

            // Photo slot
            GestureDetector(
              onTap: _pickPhoto,
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
                      if (_photo != null)
                        Image.file(_photo!, fit: BoxFit.cover)
                      else
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
                              _photo == null
                                  ? l10n.logSnapResult
                                  : l10n.logPhotoReady,
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

            ShokuLabel(l10n.logHowDidItGo),
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
                            outcomeLabel(l10n, outcome).toUpperCase(),
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

            ShokuLabel(l10n.logNoteLabel),
            const SizedBox(height: ShokuSpace.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md, vertical: 4),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.hairline),
              ),
              child: TextField(
                controller: _note,
                onChanged: (_) => setState(() {}),
                style: ShokuType.bodySmall.copyWith(color: c.ink),
                cursorColor: c.accent,
                maxLines: 2,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.logNoteHint,
                  hintStyle: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
              ),
            ),
            const SizedBox(height: ShokuSpace.lg),

            ShokuLabel(l10n.logChangeLabel),
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
                  hintText: l10n.logChangeHint,
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
                      _photo != null
                          ? l10n.logSaveWithPhoto
                          : changes.isEmpty
                              ? l10n.logSaveTonight
                              : l10n.logSaveUpgrade(
                                  widget.dish.currentVersion + 1),
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
