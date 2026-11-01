import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../screens/account/help_screen.dart';
import '../screens/cook/cook_mode_screen.dart';
import '../screens/dish/dish_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/nutrition/nutrition_coming_soon_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/recipes/recipes_screen.dart';
import '../screens/wall/wall_screen.dart';
import '../state/shoku_providers.dart';
import 'app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: previewScreen == null || previewScreen == 'home'
      ? '/journal'
      : '/$previewScreen',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/journal', builder: (_, __) => const JournalScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/recipes', builder: (_, __) => const RecipesScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/wall', builder: (_, __) => const WallScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())],
        ),
      ],
    ),
    GoRoute(
      path: '/dish/:id',
      builder: (context, state) => DishScreen(
        dishId: state.pathParameters['id'] ?? 'mousse',
      ),
    ),
    GoRoute(
      path: '/cook/:id',
      builder: (context, state) => CookModeScreen(
        dishId: state.pathParameters['id'] ?? 'mousse',
      ),
    ),
    GoRoute(path: '/nutrition', builder: (_, __) => const NutritionComingSoonScreen()),
    GoRoute(path: '/nutrition/setup', builder: (_, __) => const NutritionComingSoonScreen()),
    GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
  ],
);
