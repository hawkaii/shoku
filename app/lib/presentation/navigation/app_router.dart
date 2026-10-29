import 'package:go_router/go_router.dart';

import '../screens/account/help_screen.dart';
import '../screens/dish/dish_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/recipes/recipes_screen.dart';
import '../screens/shopping/shopping_screen.dart';
import '../state/shoku_providers.dart';
import 'app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: previewScreen == null || previewScreen == 'home'
      ? '/journal'
      : '/$previewScreen',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/journal', builder: (_, __) => const JournalScreen()),
        GoRoute(path: '/recipes', builder: (_, __) => const RecipesScreen()),
        GoRoute(path: '/groceries', builder: (_, __) => const ShoppingScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/dish/:id',
      builder: (context, state) => DishScreen(
        dishId: state.pathParameters['id'] ?? 'mousse',
      ),
    ),
    GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
  ],
);
