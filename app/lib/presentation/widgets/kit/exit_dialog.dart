import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';

/// One exit dialog, used by the app-level back guard.
Future<bool> showExitDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final c = context.colors;
      return Dialog(
        backgroundColor: c.canvas,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShokuRadius.card),
          side: BorderSide(color: c.ink, width: ShokuStroke.brutal),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ShokuSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leave Shoku?', style: ShokuType.h1.copyWith(color: c.ink)),
              const SizedBox(height: ShokuSpace.xs),
              Text(
                'Your journal is saved. Nothing is lost.',
                style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
              const SizedBox(height: ShokuSpace.lg),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ShokuRadius.chip),
                          side: BorderSide(color: c.hairline),
                        ),
                      ),
                      child: Text('Keep cooking',
                          style: ShokuType.title.copyWith(color: c.ink, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: ShokuSpace.sm),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        backgroundColor: c.ink,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ShokuRadius.chip),
                        ),
                      ),
                      child: Text('Exit',
                          style: ShokuType.title.copyWith(color: c.canvas, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
