import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Receives links and media shared from Instagram, YouTube or a browser.
/// The manifest registers the intent filters; this turns the payload into a
/// pending import.
final pendingShareProvider = StateProvider<String?>((ref) => null);

class ShareIntake {
  StreamSubscription<List<SharedMediaFile>>? _sub;

  Future<void> start(WidgetRef ref) async {
    // Cold start: the share that launched the app.
    try {
      final initial = await ReceiveSharingIntent.instance.getInitialMedia();
      _handle(ref, initial);
    } catch (_) {
      // Platform not available (web/desktop) — nothing to do.
    }

    _sub = ReceiveSharingIntent.instance.getMediaStream().listen(
          (files) => _handle(ref, files),
        );
  }

  void _handle(WidgetRef ref, List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    for (final file in files) {
      final url = _firstUrl(file.path);
      if (url != null) {
        ref.read(pendingShareProvider.notifier).state = url;
        ReceiveSharingIntent.instance.reset();
        return;
      }
    }
    ReceiveSharingIntent.instance.reset();
  }

  static final _urlPattern = RegExp(r'https?://[^\s]+');

  String? _firstUrl(String raw) {
    final match = _urlPattern.firstMatch(raw);
    return match?.group(0);
  }

  void dispose() => _sub?.cancel();
}
