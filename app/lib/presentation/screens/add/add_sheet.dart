import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/shoku_theme.dart';
import '../../widgets/kit/feedback.dart';
import 'import_sheet.dart';

Future<void> showAddSheet(BuildContext context, {String? prefill}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.canvas,
    builder: (_) => AddSheet(prefill: prefill),
  );
}

class AddSheet extends StatefulWidget {
  final String? prefill;
  const AddSheet({super.key, this.prefill});

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.prefill ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
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
            title: l10n.addSheetTitle,
            subtitle: l10n.addSheetSubtitle,
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: ShokuSpace.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.md),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(ShokuRadius.chip),
              border:
                  Border.all(color: c.hairline, width: ShokuStroke.hairline),
            ),
            child: TextField(
              controller: _controller,
              autofocus: widget.prefill == null,
              style: ShokuType.body.copyWith(color: c.ink),
              cursorColor: c.accent,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.addSheetLinkHint,
                hintStyle: ShokuType.bodySmall.copyWith(color: c.inkMuted),
              ),
            ),
          ),
          const SizedBox(height: ShokuSpace.md),
          _Option(
            icon: Icons.share_outlined,
            title: l10n.addSheetShareOption,
            subtitle: l10n.addSheetShareHint,
            onTap: () {
              // The link typed above is the link being imported; dropping it
              // here loses the import before it starts.
              final typed = _controller.text.trim();
              final link = typed.isEmpty ? widget.prefill : typed;
              Navigator.of(context).pop();
              showImportSheet(context, prefill: link);
            },
          ),
          const SizedBox(height: ShokuSpace.sm),
          _Option(
            icon: Icons.qr_code_scanner,
            title: l10n.addSheetScanOption,
            subtitle: l10n.addSheetScanHint,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: ShokuSpace.lg),
          Text(
            l10n.addSheetBackendNote,
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
                  Text(title,
                      style:
                          ShokuType.title.copyWith(color: c.ink, fontSize: 14)),
                  Text(subtitle,
                      style: ShokuType.bodySmall.copyWith(color: c.inkMuted)),
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
