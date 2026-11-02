import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/shoku_text.dart';
import '../../../data/models/pantry_item.dart';
import '../../../data/services/ocr_service.dart';
import '../../state/pantry_providers.dart';
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

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /// Receipt or screenshot: read on the device, then the same parser and the
  /// same review. The image is never uploaded.
  Future<void> _fromPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.colors.canvas,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Screenshot or photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2200,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;

    final text = await OcrService().readText(File(picked.path));
    if (!mounted) return;
    if (text == null) {
      setState(() => _note =
          'Reading text happens on the phone, so a screenshot cannot be read here. Type it below instead.');
      return;
    }
    _text.text = text;
    _review(strict: true);
  }

  void _review({bool? strict}) {
    final manager = ref.read(pantryStoreProvider.notifier);
    final lines = PantryParser.parse(
      _text.text,
      strict: strict ?? _door == _Door.photo,
      vocabulary: manager.vocabulary,
    );
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
    });
  }

  /// The review is a proposal; the cook can fix a name before it is written.
  Future<void> _rename(int index) async {
    final controller = TextEditingController(text: _lines[index].name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('What is it?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: ShokuType.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Done'),
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
          content: Text('${count(selected.length, 'item')} in the fridge')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
                  tooltip: 'Back to the fridge',
                  onPressed: () => context.pop(),
                ),
                Text('Add to the fridge',
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
                  'Photograph a receipt, say what is in the kitchen, or type it. Nothing enters the fridge until you have seen the list.',
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: ShokuSpace.md),
                Row(
                  children: [
                    _doorButton(
                        _Door.photo, 'Photo', Icons.receipt_long_outlined),
                    const SizedBox(width: ShokuSpace.xs),
                    _doorButton(_Door.voice, 'Voice', Icons.mic_none),
                    const SizedBox(width: ShokuSpace.xs),
                    _doorButton(_Door.typed, 'Type', Icons.keyboard_outlined),
                  ],
                ),
                const SizedBox(height: ShokuSpace.md),
                if (_door == _Door.typed) _typedDoor(),
                if (_door == _Door.voice) _voiceDoor(),
                if (_door == _Door.photo) _photoDoor(c),
                if (_note != null) ...[
                  const SizedBox(height: ShokuSpace.sm),
                  Text(_note!,
                      key: const ValueKey('pantry-add-note'),
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
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
                      child: Text('Review',
                          style: ShokuType.title
                              .copyWith(color: c.ink, fontSize: 13)),
                    ),
                  ),
                ),
                if (_reviewing) ...[
                  const SizedBox(height: ShokuSpace.lg),
                  const ShokuLabel('to add'),
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
                            ShokuPressable(
                              key: ValueKey('pantry-line-edit-$i'),
                              onTap: () => _rename(i),
                              child: Icon(Icons.edit_outlined,
                                  size: 15, color: c.inkMuted),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          _lines[i].amountLabel ?? 'amount unknown',
                          style: ShokuType.label
                              .copyWith(fontSize: 9, color: c.inkMuted),
                        ),
                      ),
                  if (ambiguous.isNotEmpty)
                    ExpansionTile(
                      key: const ValueKey('pantry-ambiguous'),
                      tilePadding: EdgeInsets.zero,
                      title: Text('Couldn’t read (${ambiguous.length})',
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
                          'Add ${_checked.length} of ${_lines.length}',
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
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: '2 kg rice, one per line',
          ),
        ),
      );

  Widget _voiceDoor() => MicField(
        key: const ValueKey('pantry-voice'),
        controller: _text,
        hint: 'Hold the mic and say what is in the kitchen',
        maxLines: 3,
      );

  Widget _photoDoor(ShokuColors c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShokuPressable(
            key: const ValueKey('pantry-photo'),
            onTap: _fromPhoto,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(ShokuRadius.chip),
                border: Border.all(color: c.hairline),
              ),
              child: Center(
                child: Text('Photo or screenshot',
                    style:
                        ShokuType.label.copyWith(fontSize: 10, color: c.ink)),
              ),
            ),
          ),
          const SizedBox(height: ShokuSpace.xs),
          Text(
            'Read on this device. The picture is not uploaded, and the lines land here for review.',
            style: ShokuType.label.copyWith(fontSize: 9, color: c.inkMuted),
          ),
        ],
      );

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
