import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/account/account_screen.dart';
import '../screens/account/help_screen.dart';
import '../screens/account/saves_plan_screen.dart';
import '../screens/discover/discover_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/recipe/recipe_detail_screen.dart';
import '../screens/shopping/shopping_screen.dart';
import '../screens/stash/stash_screen.dart';
import 'app_shell.dart';
import '../state/shoku_providers.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: previewScreen == null
      ? '/'
      : previewScreen == 'home'
          ? '/'
          : '/$previewScreen',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/stash', builder: (_, __) => const StashScreen()),
        GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
        GoRoute(path: '/shopping', builder: (_, __) => const ShoppingScreen()),
        GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
      ],
    ),
    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) => RecipeDetailScreen(
        itemId: state.pathParameters['id'] ?? 'mousse',
      ),
    ),
    GoRoute(path: '/saves', builder: (_, __) => const SavesPlanScreen()),
    GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
  ],
);
