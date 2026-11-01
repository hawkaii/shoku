import 'dart:async';

import 'package:flutter/material.dart';

/// A photograph over a well, with a deadline.
///
/// The design rule this implements (§12.1): a slot is painted with its monogram
/// well from the first frame, and the photo is a layer above it that fades in
/// when it arrives. If it has not arrived within [deadline] it never will —
/// an expiring CDN URL and a broken one look the same, because the difference
/// does not help anybody. Nothing here paints a bare grey rectangle or a
/// spinner, and nothing retries: a card degrades once and stays degraded.
class ShokuPhoto extends StatefulWidget {
  const ShokuPhoto({
    super.key,
    required this.provider,
    this.fit = BoxFit.cover,
    this.deadline = const Duration(seconds: 8),
    this.fade = const Duration(milliseconds: 180),
  });

  final ImageProvider provider;
  final BoxFit fit;

  /// After this, the photo is treated as failed.
  final Duration deadline;

  final Duration fade;

  @override
  State<ShokuPhoto> createState() => _ShokuPhotoState();
}

class _ShokuPhotoState extends State<ShokuPhoto> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  ImageInfo? _info;
  Timer? _deadline;
  bool _expired = false;
  ImageProvider? _resolved;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resolved != widget.provider) _resolve();
  }

  @override
  void didUpdateWidget(ShokuPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider ||
        oldWidget.deadline != widget.deadline) {
      _resolve();
    }
  }

  void _resolve() {
    _stop();
    _resolved = widget.provider;
    _info = null;
    _expired = false;

    // Nothing waits forever: an image that has not arrived by now is failed.
    _deadline = Timer(widget.deadline, () {
      if (mounted) setState(() => _expired = true);
    });

    final listener = ImageStreamListener(
      (info, wasSynchronouslyLoaded) {
        _deadline?.cancel();
        if (mounted) setState(() => _info = info);
      },
      onError: (error, stack) {
        // A failed image is the monogram, immediately and for good.
        _deadline?.cancel();
        if (mounted) setState(() => _info = null);
      },
    );

    final stream = widget.provider.resolve(createLocalImageConfiguration(context));
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  void _stop() {
    final stream = _stream;
    final listener = _listener;
    if (stream != null && listener != null) stream.removeListener(listener);
    _stream = null;
    _listener = null;
    _deadline?.cancel();
    _deadline = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    if (_expired || info == null) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: widget.fade,
      curve: Curves.easeOut,
      builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
      child: RawImage(image: info.image, fit: widget.fit),
    );
  }
}
