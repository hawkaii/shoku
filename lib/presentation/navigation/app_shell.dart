import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/kit/nav.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = [
    ShokuTabItem(Icons.home_outlined, Icons.home, 'Home'),
    ShokuTabItem(Icons.bookmark_border, Icons.bookmark, 'Stash'),
    ShokuTabItem(Icons.menu_book_outlined, Icons.menu_book, 'Discover'),
    ShokuTabItem(Icons.shopping_basket_outlined, Icons.shopping_basket, 'Shopping'),
    ShokuTabItem(Icons.person_outline, Icons.person, 'Account'),
  ];

  static const _paths = ['/', '/stash', '/discover', '/shopping', '/account'];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _paths.indexWhere((p) => p == path).clamp(0, _paths.length - 1);

    return Scaffold(
      body: child,
      bottomNavigationBar: ShokuTabBar(
        items: _tabs,
        index: index,
        onChanged: (i) => context.go(_paths[i]),
      ),
    );
  }
}
