import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/shoku_theme.dart';
import '../../data/services/share_intake.dart';
import '../screens/add/add_sheet.dart';
import '../state/shoku_providers.dart';
import '../widgets/kit/nav.dart';

class AppShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell shell;
  const AppShell({super.key, required this.shell});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _tabs = [
    ShokuTabItem(Icons.menu_book_outlined, Icons.menu_book, 'Journal'),
    ShokuTabItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Cookbook'),
    ShokuTabItem(Icons.grid_view_outlined, Icons.grid_view, 'Wall'),
    ShokuTabItem(Icons.person_outline, Icons.person, 'You'),
  ];

  final _intake = ShareIntake();
  bool _askedToExit = false;

  @override
  void initState() {
    super.initState();
    _intake.start(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingShare());
  }

  @override
  void dispose() {
    _intake.dispose();
    super.dispose();
  }

  void _consumePendingShare() {
    final url = ref.read(pendingShareProvider);
    if (url == null || !mounted) return;
    ref.read(pendingShareProvider.notifier).state = null;
    HapticFeedback.mediumImpact();
    showAddSheet(context, prefill: url);
  }

  Future<void> _handleBack() async {
    if (widget.shell.currentIndex != 0) {
      widget.shell.goBranch(0);
      return;
    }
    if (_askedToExit) return;
    _askedToExit = true;
    final leave = await showDialog<bool>(context: context, builder: (_) => const _ExitDialog());
    _askedToExit = false;
    if (leave == true) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(pendingShareProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingShare());
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        body: widget.shell,
        bottomNavigationBar: ShokuTabBar(
          items: _tabs,
          index: widget.shell.currentIndex,
          onChanged: (i) => widget.shell.goBranch(
            i,
            initialLocation: i == widget.shell.currentIndex,
          ),
          onCenterTap: () => showAddSheet(context),
        ),
      ),
    );
  }
}

class _ExitDialog extends StatelessWidget {
  const _ExitDialog();

  @override
  Widget build(BuildContext context) {
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
  }
}
