import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../screens/account/help_screen.dart';
import '../screens/cook/cook_mode_screen.dart';
import '../screens/dish/dish_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/nutrition/nutrition_coming_soon_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/pantry/pantry_add_screen.dart';
import '../screens/pantry/pantry_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/recipes/recipes_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/wall/wall_screen.dart';
import '../state/shoku_providers.dart';
import 'app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// What the router needs to know before it can build a page.
///
/// It is read by [appRouter]'s redirect and written by `ShokuApp` from the two
/// providers that decide the first screen. Keeping it out of the widget tree is
/// what lets the app be **one** `MaterialApp.router` from the first frame: no
/// splash app is ever torn down under a live route.
class AppGate {
  AppGate._();

  static bool authReady = false;
  static bool onboarded = false;

  static void reset() {
    authReady = false;
    onboarded = false;
  }
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: previewScreen == null || previewScreen == 'home'
      ? '/journal'
      : '/$previewScreen',
  // Redirect, not a second app: onboarding and the splash are routes.
  redirect: (context, state) {
    final path = state.uri.path;
    if (!AppGate.onboarded) {
      return path == '/welcome' ? null : '/welcome';
    }
    if (!AppGate.authReady) {
      return path == '/splash' ? null : '/splash';
    }
    if (path == '/welcome' || path == '/splash') return '/journal';
    return null;
  },
  routes: [
    GoRoute(path: '/welcome', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/journal', builder: (_, __) => const JournalScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/recipes', builder: (_, __) => const RecipesScreen())],
        ),
        // The fridge is a destination, not a page pushed over the shell: it
        // keeps the tab bar, deep-links at /pantry, and /fridge is its alias.
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pantry',
              builder: (_, __) => const PantryScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (_, __) => const PantryAddScreen(),
                ),
              ],
            ),
          ],
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
    // One screen, two words for it.
    GoRoute(path: '/fridge', redirect: (_, __) => '/pantry'),
    GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
  ],
);
