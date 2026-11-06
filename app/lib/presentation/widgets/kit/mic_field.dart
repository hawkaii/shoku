import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../../core/utils/failure_log.dart';
import 'motion.dart';

/// Push-to-talk text field. The mic is live only while pressed — that press is
/// the consent gesture, and it is visible.
class MicField extends StatefulWidget {
  final TextEditingController controller;
  final String? hint;
  final int maxLines;

  /// Composer-off: cap reached, offline, or a change waiting on an answer.
  final bool enabled;

  const MicField({
    super.key,
    required this.controller,
    this.hint,
    this.maxLines = 3,
    this.enabled = true,
  });

  @override
  State<MicField> createState() => _MicFieldState();
}

class _MicFieldState extends State<MicField> {
  final _speech = SpeechToText();
  bool _listening = false;
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _speech.initialize().then((ok) {
      if (mounted) setState(() => _available = ok);
    }).catchError((Object error, StackTrace stack) {
      // Speech is optional platform work: no engine on this build means the
      // field stays a plain text field, which is a complete input method.
      logFailure('speech initialize', error, stack);
    });
  }

  Future<void> _start() async {
    if (!_available) return;
    setState(() => _listening = true);
    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          final text = result.recognizedWords;
          if (text.isNotEmpty) widget.controller.text = text;
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (error, stack) {
      // Typing still works; only this press of the mic did not.
      logFailure('speech listen', error, stack);
      setState(() => _listening = false);
    }
  }

  Future<void> _stop() async {
    setState(() => _listening = false);
    try {
      await _speech.stop();
    } catch (_) {
      // Optional platform work: no engine means nothing was listening, so there
      // is nothing to stop. The widget's own state is corrected below.
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md, vertical: 6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ShokuRadius.chip),
        border: Border.all(
          color: _listening ? c.accent : c.hairline,
          width: _listening ? ShokuStroke.brutal : ShokuStroke.hairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled,
              maxLines: widget.maxLines,
              minLines: 1,
              style: ShokuType.bodySmall.copyWith(color: c.ink),
              cursorColor: c.accent,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _listening ? l10n.micListening : (widget.hint ?? l10n.micHint),
                hintStyle: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
            ),
          ),
          const SizedBox(width: ShokuSpace.sm),
          ShokuPressable(
            onTap: () {},
            child: GestureDetector(
              onLongPressStart: widget.enabled ? (_) => _start() : null,
              onLongPressEnd: widget.enabled ? (_) => _stop() : null,
              onTap: widget.enabled && _available ? _start : null,
              child: AnimatedContainer(
                duration: ShokuMotion.toggle,
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _listening ? c.accent : c.surfaceAlt,
                  borderRadius: BorderRadius.circular(ShokuRadius.chip),
                  border: Border.all(color: _listening ? c.accent : c.hairline),
                ),
                child: Icon(
                  _listening ? Icons.mic : Icons.mic_none,
                  size: 17,
                  color: _listening ? c.onAccent : c.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
