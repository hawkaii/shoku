import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/l10n/labels.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/failure_log.dart';
import '../../../data/models/pantry_item.dart';
import '../../../data/services/api_client.dart';
import '../../../data/services/pantry_ai_service.dart';
import '../../../data/services/prefs.dart';
import '../../../data/services/receipt_image.dart';
import '../../state/pantry_providers.dart';
import '../../state/sync_providers.dart';
import '../../widgets/kit/foundation.dart';
import '../../widgets/kit/mic_field.dart';
import '../../widgets/kit/motion.dart';

/// Adding to the fridge is a page, not a sheet.
///
/// A sheet can be dragged away mid-thought and leaves the half-typed list in no
/// state at all. Here the three doors sit at the top, the review sits under
/// them, and the back arrow always means "back to the fridge".
class PantryAddScreen extends ConsumerStatefulWidget {
  const PantryAddScreen({super.key});

  @override
  ConsumerState<PantryAddScreen> createState() => _PantryAddScreenState();
}

enum _Door { photo, voice, typed }

class _PantryAddScreenState extends ConsumerState<PantryAddScreen> {
  final _text = TextEditingController();
  List<ParsedPantryLine> _lines = const [];
  final _checked = <int>{};
  bool _reviewing = false;
  bool _busy = false;
  _Door _door = _Door.typed;
  String? _note;

  /// The fallback is in flight: quiet, because it is an improvement to a list
  /// that already exists, not a thing the cook is waiting on.
  bool _readingAi = false;

  /// The day's receipts are spent. Set once, never retried.
  String? _capNote;

  /// Guards an in-flight call: a review started after this one owns the sheet.
  int _generation = 0;

  /// The vision read is in flight. The picker has already returned, so the cook
  /// is waiting on the model, not on their own phone.
  bool _readingPhoto = false;

  /// The reader has no way out: no connection, or every attempt failed. Typed
  /// and voice are unaffected and stay offered.
  bool _photoOffline = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /// Receipt or screenshot: the model reads the image, and the same review
  /// sheet takes it from there.
  ///
  /// This used to be on-device OCR. It could not read a real till slip, so the
  /// picture goes to the server's vision model instead — and the cook is told
  /// that once, before the first upload.
  Future<void> _fromPhoto() async {
    if (_photoOffline || ref.read(syncStatusProvider) == SyncStatus.offline) {
      return;
    }
    await _discloseOnce();
    if (!mounted) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.colors.canvas,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.pantryScreenshotOrPhoto),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.l10n.pantryCamera),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final bytes = await ref.read(receiptImagePickerProvider)(source);
    if (bytes == null || !mounted) return;
    await _readImage(bytes);
  }

  /// One sheet, once per device: the image leaves the phone.
  Future<void> _discloseOnce() async {
    // A missing prefs store only means the sheet is shown again next time: the
    // disclosure is safer repeated than skipped.
    final seen = await Prefs.receiptVisionSeen()
        .catchError((Object error, StackTrace stack) {
      logFailure('vision disclosure read', error, stack);
      return false;
    });
    if (seen || !mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.canvas,
      builder: (context) => const _VisionDisclosure(),
    );
    // Remembered even when it is swiped away: asking twice is not consent.
    // Failing to remember it costs one repeated sheet, never a lost entry.
    unawaited(Prefs.setReceiptVisionSeen(true)
        .catchError((Object error, StackTrace stack) {
      logFailure('vision disclosure write', error, stack);
    }));
  }

  Future<void> _readImage(List<int> bytes) async {
    setState(() {
      _readingPhoto = true;
      _note = null;
      _capNote = null;
    });

    PantryAiResult? result;
    String? cap;
    var offline = false;
    try {
      result = await ref.read(pantryVisionServiceProvider).read(
            bytes,
            mimeType: ReceiptImage.mimeTypeOf(bytes),
          );
    } on PantryCapReached {
      cap = 'cap';
    } on ApiError {
      // The server had a day. The rows already parsed stay; try again later.
    } catch (error, stack) {
      // The rows already parsed stay on screen; the line says why the rest did
      // not arrive.
      logFailure('receipt photo read', error, stack);
      offline = true;
    }
    if (!mounted) return;

    setState(() {
      _readingPhoto = false;
      _capNote = cap;
      _photoOffline = offline;
      if (offline) {
        _note = 'offline';
      } else if (result != null && result.items.isEmpty) {
        // An unreadable picture is an empty list, never an error dialog.
        _note = 'unreadable';
      } else if (result != null) {
        _mergeVision(result.items);
      }
    });
  }

  /// Image items land in the same review as everything else: checked, and
  /// marked as the model's reading.
  void _mergeVision(List<AiPantryLine> items) {
    final merged = [..._lines];
    for (final item in items) {
      final line = ParsedPantryLine(
        raw: item.line,
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
        confident: true,
        fromAi: true,
      );
      final at = merged.indexWhere(
        (existing) => PantryParser.key(existing.raw) == PantryParser.key(item.line),
      );
      if (at >= 0) {
        merged[at] = line;
        _checked.add(at);
      } else {
        merged.add(line);
        _checked.add(merged.length - 1);
      }
    }
    _lines = merged;
    _reviewing = _lines.isNotEmpty;
    _note = null;
  }

  void _review({bool? strict}) {
    final manager = ref.read(pantryStoreProvider.notifier);
    final vocabulary = manager.vocabulary;
    final lines = PantryParser.parse(
      _text.text,
      strict: strict ?? _door == _Door.photo,
      vocabulary: vocabulary,
    );
    final generation = ++_generation;
    setState(() {
      _lines = lines;
      _checked
        ..clear()
        ..addAll([
          for (var i = 0; i < lines.length; i++)
            if (lines[i].confident) i,
        ]);
      _reviewing = lines.isNotEmpty;
      _note = null;
      _capNote = null;
      _readingAi = false;
    });
    unawaited(_readTheRest(generation, vocabulary));
  }

  /// One batched call for the lines the device could not be trusted with.
  ///
  /// Never one per line, and never at all when the receipt parsed cleanly. The
  /// image is not here either: this sends the leftover text and nothing else.
  Future<void> _readTheRest(int generation, Set<String> vocabulary) async {
    final leftovers = <String>{
      for (final line in _lines)
        if (PantryParser.needsHelp(line, vocabulary)) line.raw.trim(),
    }.take(PantryAiService.maxLines).toList();
    if (leftovers.isEmpty || generation != _generation) return;

    setState(() => _readingAi = true);
    PantryAiResult? result;
    String? cap;
    try {
      result = await ref.read(pantryAiServiceProvider).read(leftovers);
    } on PantryCapReached {
      cap = 'cap';
    } catch (error, stack) {
      // Offline, or the server is having a day. The parsed rows still stand and
      // a failed call never blocks adding them — but it is no longer invisible.
      logFailure('pantry ai read', error, stack);
    }
    if (!mounted || generation != _generation) return;
    setState(() {
      _readingAi = false;
      _capNote = cap;
      if (result != null) _mergeAi(result.items);
    });
  }

  /// The server echoes each line so it can be matched back by its own words.
  /// A line the model omitted keeps whatever the device made of it.
  void _mergeAi(List<AiPantryLine> items) {
    if (items.isEmpty) return;
    final byLine = <String, AiPantryLine>{};
    for (final item in items) {
      byLine.putIfAbsent(item.line.trim(), () => item);
    }
    final merged = [..._lines];
    for (var i = 0; i < merged.length; i++) {
      final hit = byLine[merged[i].raw.trim()];
      if (hit == null) continue;
      // The model's name wins, but a model that states no amount must not
      // erase one the device already read.
      merged[i] = ParsedPantryLine(
        raw: merged[i].raw,
        name: hit.name,
        quantity: hit.quantity ?? merged[i].quantity,
        unit: hit.quantity == null ? merged[i].unit : hit.unit,
        confident: true,
        fromAi: true,
      );
      _checked.add(i);
    }
    _lines = merged;
  }

  /// The review is a proposal; the cook can fix a name before it is written.
  Future<void> _rename(int index) async {
    final controller = TextEditingController(text: _lines[index].name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.pantryWhatIsIt),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: ShokuType.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.pantryCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(context.l10n.pantryDone),
          ),
        ],
      ),
    );
    final cleaned = PantryParser.cleanName(name ?? '');
    if (cleaned.isEmpty) return;
    setState(() {
      _lines = [
        for (var i = 0; i < _lines.length; i++)
          if (i == index)
            ParsedPantryLine(
              raw: _lines[i].raw,
              name: cleaned,
              quantity: _lines[i].quantity,
              unit: _lines[i].unit,
              confident: _lines[i].confident,
            )
          else
            _lines[i],
      ];
    });
  }

  Future<void> _confirm() async {
    final selected = [
      for (var i = 0; i < _lines.length; i++)
        if (_checked.contains(i) && _lines[i].confident) _lines[i],
    ];
    if (selected.isEmpty || _busy) return;
    setState(() => _busy = true);
    final store = ref.read(pantryStoreProvider.notifier);
    for (final line in selected) {
      await store.confirmLine(line, source: _door.name);
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      SnackBar(
          content: Text(context.l10n.pantryInFridgeSnack(selected.length))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final ambiguous = [
      for (var i = 0; i < _lines.length; i++)
        if (!_lines[i].confident) i,
    ];

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ShokuSpace.md,
              ShokuSpace.sm,
              ShokuSpace.lg,
              ShokuSpace.sm,
            ),
            child: Row(
              children: [
                IconButton(
                  key: const ValueKey('pantry-add-back'),
                  icon: const Icon(Icons.arrow_back),
                  color: c.ink,
                  tooltip: l10n.pantryBackTooltip,
                  onPressed: () => context.pop(),
                ),
                Text(l10n.pantryAddTitle,
                    style: ShokuType.h2.copyWith(color: c.ink)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                ShokuSpace.lg,
                0,
                ShokuSpace.lg,
                ShokuSpace.xxl,
              ),
              children: [
                Text(
                  l10n.pantryAddIntro,
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: ShokuSpace.md),
                Row(
                  children: [
                    _doorButton(_Door.photo, l10n.pantryDoorPhoto,
                        Icons.receipt_long_outlined),
                    const SizedBox(width: ShokuSpace.xs),
                    _doorButton(
                        _Door.voice, l10n.pantryDoorVoice, Icons.mic_none),
                    const SizedBox(width: ShokuSpace.xs),
                    _doorButton(_Door.typed, l10n.pantryDoorType,
                        Icons.keyboard_outlined),
                  ],
                ),
                const SizedBox(height: ShokuSpace.md),
                if (_door == _Door.typed) _typedDoor(),
                if (_door == _Door.voice) _voiceDoor(),
                if (_door == _Door.photo) _photoDoor(c),
                if (_note != null) ...[
                  const SizedBox(height: ShokuSpace.sm),
                  Text(
                      _note == 'offline'
                          ? l10n.pantryNoteOffline
                          : l10n.pantryNoteUnreadable,
                      key: const ValueKey('pantry-add-note'),
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                ],
                if (_capNote != null) ...[
                  const SizedBox(height: ShokuSpace.sm),
                  Text(
                    l10n.pantryCapReached,
                    key: const ValueKey('pantry-ai-cap'),
                    style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                  ),
                ],
                const SizedBox(height: ShokuSpace.md),
                ShokuPressable(
                  key: const ValueKey('pantry-parse'),
                  onTap: () => _review(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      border: Border.all(color: c.hairline),
                    ),
                    child: Center(
                      child: Text(l10n.pantryReview,
                          style: ShokuType.title
                              .copyWith(color: c.ink, fontSize: 13)),
                    ),
                  ),
                ),
                if (_reviewing) ...[
                  const SizedBox(height: ShokuSpace.lg),
                  ShokuLabel(l10n.pantryToAdd),
                  if (_readingAi) ...[
                    const SizedBox(height: ShokuSpace.xs),
                    Text(
                      l10n.pantryAiReading,
                      key: const ValueKey('pantry-ai-reading'),
                      style: ShokuType.label
                          .copyWith(fontSize: 9, color: c.inkMuted),
                    ),
                  ],
                  const SizedBox(height: ShokuSpace.xs),
                  for (var i = 0; i < _lines.length; i++)
                    if (_lines[i].confident)
                      CheckboxListTile(
                        key: ValueKey('pantry-line-$i'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: _checked.contains(i),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _checked.add(i);
                          } else {
                            _checked.remove(i);
                          }
                        }),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(_lines[i].name,
                                  style: ShokuType.bodySmall
                                      .copyWith(color: c.ink)),
                            ),
                            if (_lines[i].fromAi)
                              Container(
                                key: ValueKey('pantry-ai-chip-$i'),
                                margin:
                                    const EdgeInsets.only(right: ShokuSpace.xs),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: c.surfaceAlt,
                                  borderRadius:
                                      BorderRadius.circular(ShokuRadius.chip),
                                  border: Border.all(color: c.hairline),
                                ),
                                child: Text('AI',
                                    style: ShokuType.label.copyWith(
                                        fontSize: 8, color: c.inkMuted)),
                              ),
                            ShokuPressable(
                              key: ValueKey('pantry-line-edit-$i'),
                              onTap: () => _rename(i),
                              child: Icon(Icons.edit_outlined,
                                  size: 15, color: c.inkMuted),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          pantryAmount(l10n, locale, _lines[i].quantity,
                                  _lines[i].unit)
                              .isEmpty
                              ? l10n.pantryAmountUnknown
                              : pantryAmount(l10n, locale, _lines[i].quantity,
                                  _lines[i].unit),
                          style: ShokuType.label
                              .copyWith(fontSize: 9, color: c.inkMuted),
                        ),
                      ),
                  if (ambiguous.isNotEmpty)
                    ExpansionTile(
                      key: const ValueKey('pantry-ambiguous'),
                      tilePadding: EdgeInsets.zero,
                      title: Text(l10n.pantryCouldNotRead(ambiguous.length),
                          style: ShokuType.label.copyWith(color: c.inkMuted)),
                      children: [
                        for (final index in ambiguous)
                          ListTile(
                            dense: true,
                            title: Text(_lines[index].raw,
                                style: ShokuType.bodySmall
                                    .copyWith(color: c.inkMuted)),
                          ),
                      ],
                    ),
                  const SizedBox(height: ShokuSpace.sm),
                  ShokuPressable(
                    key: const ValueKey('pantry-confirm'),
                    onTap: _checked.isEmpty || _busy ? null : _confirm,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: ShokuGradients.crimsonPress,
                        borderRadius: BorderRadius.circular(ShokuRadius.chip),
                        border:
                            Border.all(color: c.ink, width: ShokuStroke.brutal),
                      ),
                      child: Center(
                        child: Text(
                          l10n.pantryConfirmAdd(_checked.length, _lines.length),
                          key: const ValueKey('pantry-confirm-label'),
                          style: ShokuType.title
                              .copyWith(color: c.onAccent, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _doorButton(_Door door, String label, IconData icon) {
    final c = context.colors;
    final active = _door == door;
    return Expanded(
      child: ShokuPressable(
        key: ValueKey('pantry-door-${door.name}'),
        onTap: () => setState(() {
          _door = door;
          _note = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? c.accentSoft : c.surface,
            borderRadius: BorderRadius.circular(ShokuRadius.chip),
            border: Border.all(color: active ? c.accent : c.hairline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: active ? c.accent : c.inkMuted),
              const SizedBox(width: 5),
              Text(label,
                  style: ShokuType.label.copyWith(
                      fontSize: 10, color: active ? c.accent : c.inkMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typedDoor() => _field(
        child: TextField(
          key: const ValueKey('pantry-text'),
          controller: _text,
          maxLines: 4,
          minLines: 3,
          style: ShokuType.bodySmall,
          onChanged: (_) => setState(() => _reviewing = false),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: context.l10n.pantryTypeHint,
          ),
        ),
      );

  Widget _voiceDoor() => MicField(
        key: const ValueKey('pantry-voice'),
        controller: _text,
        hint: context.l10n.pantryVoiceHint,
        maxLines: 3,
      );

  Widget _photoDoor(ShokuColors c) {
    final l10n = context.l10n;
    final offline =
        _photoOffline || ref.watch(syncStatusProvider) == SyncStatus.offline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShokuPressable(
          key: const ValueKey('pantry-photo'),
          onTap: offline ? null : _fromPhoto,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: offline ? c.surfaceAlt : c.surface,
              borderRadius: BorderRadius.circular(ShokuRadius.chip),
              border: Border.all(color: c.hairline),
            ),
            child: Center(
              child: Text(l10n.pantryPhotoButton,
                  style: ShokuType.label.copyWith(
                      fontSize: 10, color: offline ? c.inkMuted : c.ink)),
            ),
          ),
        ),
        const SizedBox(height: ShokuSpace.xs),
        Text(
          offline ? l10n.pantryNoteOffline : l10n.pantryPhotoHint,
          key: const ValueKey('pantry-photo-copy'),
          style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted),
        ),
        if (_readingPhoto) ...[
          const SizedBox(height: ShokuSpace.sm),
          Text(
            l10n.pantryReadingReceipt,
            key: const ValueKey('pantry-vision-reading'),
            style: ShokuType.label.copyWith(fontSize: 9, color: c.accent),
          ),
        ],
      ],
    );
  }

  Widget _field({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ShokuSpace.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.chip),
          border: Border.all(color: context.colors.hairline),
        ),
        child: child,
      );
}

/// The trade, said once: the picture leaves the phone for Meta's model.
class _VisionDisclosure extends StatelessWidget {
  const _VisionDisclosure();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShokuSpace.lg,
        ShokuSpace.lg,
        ShokuSpace.lg,
        ShokuSpace.xl,
      ),
      child: Column(
        key: const ValueKey('pantry-vision-disclosure'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.pantryVisionTitle,
              style: ShokuType.h2.copyWith(color: c.ink)),
          const SizedBox(height: ShokuSpace.xs),
          Text(
            l10n.pantryVisionBody,
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
          const SizedBox(height: ShokuSpace.md),
          ShokuPressable(
            key: const ValueKey('pantry-vision-disclosure-ok'),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: ShokuGradients.crimsonPress,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.ink, width: ShokuStroke.brutal),
              ),
              child: Center(
                child: Text(l10n.pantryGotIt,
                    style: ShokuType.title
                        .copyWith(color: c.onAccent, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
