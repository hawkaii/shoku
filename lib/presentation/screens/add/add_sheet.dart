import 'package:flutter/material.dart';

import '../../../core/theme/shoku_theme.dart';
import '../../widgets/kit/feedback.dart';

Future<void> showAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => const AddSheet(),
  );
}

class AddSheet extends StatelessWidget {
  const AddSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(
        left: ShokuSpace.lg,
        right: ShokuSpace.lg,
        top: ShokuSpace.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + ShokuSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShokuSheetHeader(
            title: 'Import a recipe',
            subtitle: 'One reel becomes one dish you can cook and version.',
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: ShokuSpace.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(ShokuRadius.chip),
              border: Border.all(color: c.hairline, width: ShokuStroke.hairline),
            ),
            child: TextField(
              autofocus: true,
              style: ShokuType.body.copyWith(color: c.ink),
              cursorColor: c.accent,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Paste an Instagram or YouTube link',
                hintStyle: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
            ),
          ),
          const SizedBox(height: ShokuSpace.md),
          _Option(
            icon: Icons.share_outlined,
            title: 'Share from another app',
            subtitle: 'Instagram → share → Shoku',
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: ShokuSpace.sm),
          _Option(
            icon: Icons.qr_code_scanner,
            title: 'Scan a barcode',
            subtitle: 'Add straight to your pantry',
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: ShokuSpace.lg),
          Text(
            'Extraction runs on the backend — this build is the interface only.',
            style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(ShokuSpace.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(ShokuRadius.card),
          border: Border.all(color: c.hairline, width: ShokuStroke.hairline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: c.ink),
            const SizedBox(width: ShokuSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
                  Text(subtitle, style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: c.inkMuted),
          ],
        ),
      ),
    );
  }
}
