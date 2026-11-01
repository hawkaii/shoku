import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';
import 'photo.dart';

/// Dish photography. Photos carry the colour in this app, so every card gets a
/// real image — but never a grey box while one is missing.
///
/// §12.1: the slot is sized by its container, painted from the first frame with
/// the monogram well, and the photo fades in above it within 8 seconds or not at
/// all. A network image that fails, a local file that was deleted and a URL that
/// has expired all end in the same place: the monogram.
class ShokuDishImage extends StatelessWidget {
  final String url;
  final String title;
  final double? height;
  final double radius;
  final BoxFit fit;
  final bool heroTag;

  /// Exposed so a slow photo can be tested without waiting eight seconds.
  final Duration deadline;

  const ShokuDishImage({
    super.key,
    required this.url,
    required this.title,
    this.height,
    this.radius = 8,
    this.fit = BoxFit.cover,
    this.heroTag = false,
    this.deadline = const Duration(seconds: 8),
  });

  ImageProvider? get _provider {
    if (url.isEmpty) return null;
    if (url.startsWith('/') || url.startsWith('file://')) {
      // The web has no file system; a local path there is simply no photo.
      if (kIsWeb) return null;
      return FileImage(File(url.replaceFirst('file://', '')));
    }
    return NetworkImage(url);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _MonogramWell(title: title),
          if (provider != null)
            ShokuPhoto(provider: provider, fit: fit, deadline: deadline),
          // 1px keyline locks the photo into the paper grid.
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: context.colors.ink.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: heroTag ? Hero(tag: 'dish-$title', child: image) : image,
    );
  }
}

/// The well: the one thing an image slot may ever be when it has no photo.
class _MonogramWell extends StatelessWidget {
  const _MonogramWell({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initial =
        title.trim().isEmpty ? '·' : title.trim().characters.first.toUpperCase();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : 96.0;
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : width;
        final size = math.min(math.min(width, height) * 0.42, 48.0);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.accentSoft, c.surfaceAlt],
            ),
          ),
          child: Center(
            child: Text(
              initial,
              style: ShokuType.display.copyWith(
                fontSize: size,
                color: c.accent.withValues(alpha: 0.55),
              ),
            ),
          ),
        );
      },
    );
  }
}
