import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';

/// Dish photography. Photos carry the colour in this app, so every card gets a
/// real image; when the network is unavailable the fallback is a designed
/// "kitchen stamp" rather than a broken box.
class ShokuDishImage extends StatelessWidget {
  final String url;
  final String title;
  final double? height;
  final double radius;
  final BoxFit fit;
  final bool heroTag;

  const ShokuDishImage({
    super.key,
    required this.url,
    required this.title,
    this.height,
    this.radius = 8,
    this.fit = BoxFit.cover,
    this.heroTag = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url.startsWith('/') || url.startsWith('file://'))
            Image.file(
              File(url.replaceFirst('file://', '')),
              fit: fit,
              errorBuilder: (context, error, stack) => _Fallback(title: title),
            )
          else
            Image.network(
              url,
              fit: fit,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(color: c.surfaceAlt);
              },
              errorBuilder: (context, error, stack) => _Fallback(title: title),
            ),
          // 1px keyline locks the photo into the paper grid.
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: c.ink.withValues(alpha: 0.10),
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
      child: heroTag
          ? Hero(tag: 'dish-$title', child: image)
          : image,
    );
  }
}

class _Fallback extends StatelessWidget {
  final String title;
  const _Fallback({required this.title});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
          title.characters.first.toUpperCase(),
          style: ShokuType.display.copyWith(
            fontSize: 40,
            color: c.accent.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
