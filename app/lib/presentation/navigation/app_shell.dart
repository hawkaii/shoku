import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/kit/nav.dart';
import '../screens/add/add_sheet.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = [
    ShokuTabItem(Icons.menu_book_outlined, Icons.menu_book, 'Journal'),
    ShokuTabItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Cookbook'),
    ShokuTabItem(Icons.shopping_basket_outlined, Icons.shopping_basket, 'Groceries'),
    ShokuTabItem(Icons.person_outline, Icons.person, 'You'),
  ];

  static const _paths = ['/journal', '/recipes', '/groceries', '/profile'];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _paths
        .indexWhere((p) => path.startsWith(p))
        .clamp(0, _paths.length - 1)
        .toInt();

    return Scaffold(
      body: child,
      bottomNavigationBar: ShokuTabBar(
        items: _tabs,
        index: index,
        onChanged: (i) => context.go(_paths[i]),
        onCenterTap: () => showAddSheet(context),
      ),
    );
  }
}
