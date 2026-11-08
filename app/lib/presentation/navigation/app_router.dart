import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/shoku_theme.dart';
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
import '../widgets/kit/motion.dart';
import '../widgets/kit/plate_mark.dart';
import 'app_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// What the router needs to know before it can build a page.
///
/// It is read by [appGateRedirect] and written by `ShokuApp` from the two
/// providers that decide the first screen. Keeping it out of the widget tree is
/// what lets the app be **one** `MaterialApp.router` from the first frame: no
/// splash app is ever torn down under a live route.
class AppGate {
  AppGate._();

  static bool authReady = false;
  static bool onboarded = false;

  /// Where the user was actually going when the gate turned them away.
  ///
  /// A link can arrive before onboarding is finished, or before the session has
  /// an answer. Answering it means redirecting to `/welcome` or `/splash`, and
  /// without this the destination would be gone by the time the gate opens.
  /// [appGateRedirect] writes it and delivers it exactly once.
  static String? destination;

  /// True once the gate has let the user through. After that a redirect to the
  /// splash is not an interrupted attempt — there is nothing to remember, and
  /// the gate's default is the journal.
  static bool opened = false;

  /// The gate's own routes. They are never a destination: remembering one
  /// would have the gate redirect to itself forever.
  static bool isGateRoute(String path) =>
      path == '/welcome' || path == '/splash';

  /// Keeps the first location the gate turned away. A later redirect (the gate
  /// closing again, a `refresh()`) must not overwrite it.
  static void remember(String location) {
    if (opened) return;
    destination = location;
  }

  static void reset() {
    authReady = false;
    onboarded = false;
    destination = null;
    opened = false;
  }
}

/// The gate. One function so a test can drive it with its own router instead of
/// booting the whole app.
///
/// Onboarding is local, so it is answered first; the session then decides
/// whether the splash may be left. Whatever the user asked for in the meantime
/// is delivered on the first pass where both gates are open, then forgotten.
String? appGateRedirect(BuildContext context, GoRouterState state) {
  final path = state.uri.path;
  final location = state.uri.toString();
  final gateRoute = AppGate.isGateRoute(path);

  if (!AppGate.onboarded) {
    if (path == '/welcome') return null;
    if (!gateRoute) AppGate.remember(location);
    return '/welcome';
  }

  if (!AppGate.authReady) {
    if (path == '/splash') return null;
    if (!gateRoute) AppGate.remember(location);
    return '/splash';
  }

  final destination = AppGate.destination;
  AppGate.destination = null;
  if (destination != null && destination != location) return destination;
  if (gateRoute) return '/journal';
  AppGate.opened = true;
  return null;
}

/// A path that matches no route, and a page that threw, both land here instead
/// of on GoRouter's red screen. The failure is logged once per mount; the user
/// gets copy and a way back.
class RouteErrorScreen extends StatefulWidget {
  final String location;

  const RouteErrorScreen({super.key, required this.location});

  @override
  State<RouteErrorScreen> createState() => _RouteErrorScreenState();
}

class _RouteErrorScreenState extends State<RouteErrorScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('route: no page for ${widget.location}');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: c.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: ShokuSpace.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PlateMark(size: 72),
                const SizedBox(height: ShokuSpace.lg),
                Text(
                  l10n.routeErrorTitle,
                  textAlign: TextAlign.center,
                  style: ShokuType.h2.copyWith(color: c.ink),
                ),
                const SizedBox(height: ShokuSpace.sm),
                Text(
                  l10n.routeErrorBody,
                  textAlign: TextAlign.center,
                  style: ShokuType.bodySmall.copyWith(color: c.inkMuted),
                ),
                const SizedBox(height: ShokuSpace.xl),
                ShokuPressable(
                  key: const ValueKey('route-error-back'),
                  onTap: () => context.go('/journal'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ShokuSpace.lg,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: c.accent,
                      borderRadius: BorderRadius.circular(ShokuRadius.chip),
                      border: Border.all(
                        color: c.ink,
                        width: ShokuStroke.brutal,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.ink,
                          offset: ShokuStroke.brutalShadow,
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      l10n.routeErrorBack,
                      style: ShokuType.title.copyWith(
                        color: c.onAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildRouteError(BuildContext context, GoRouterState state) =>
    RouteErrorScreen(location: state.uri.toString());

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: previewScreen == null || previewScreen == 'home'
      ? '/journal'
      : '/$previewScreen',
  // Redirect, not a second app: onboarding and the splash are routes.
  redirect: appGateRedirect,
  errorBuilder: buildRouteError,
  routes: [
    GoRoute(path: '/welcome', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/journal', builder: (_, __) => const JournalScreen())
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/recipes', builder: (_, __) => const RecipesScreen())
          ],
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
          routes: [
            GoRoute(path: '/wall', builder: (_, __) => const WallScreen())
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())
          ],
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
    GoRoute(
        path: '/nutrition',
        builder: (_, __) => const NutritionComingSoonScreen()),
    GoRoute(
        path: '/nutrition/setup',
        builder: (_, __) => const NutritionComingSoonScreen()),
    // One screen, two words for it.
    GoRoute(path: '/fridge', redirect: (_, __) => '/pantry'),
    GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
  ],
);
