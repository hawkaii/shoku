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

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(pendingShareProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingShare());
      }
    });

    return Scaffold(
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
    );
  }
}
