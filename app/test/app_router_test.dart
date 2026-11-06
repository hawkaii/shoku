import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/l10n/app_localizations.dart';
import 'package:food_finder/main.dart';
import 'package:food_finder/presentation/navigation/app_router.dart';
import 'package:food_finder/presentation/state/auth_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/presentation/state/shoku_providers.dart';
import 'package:go_router/go_router.dart';

/// A router with the production gate and the production error screen, over
/// cheap pages. The gate is the thing under test; the tables behind the real
/// Journal are not.
GoRouter _testRouter() => GoRouter(
      redirect: appGateRedirect,
      initialLocation: '/journal',
      errorBuilder: buildRouteError,
      routes: [
        GoRoute(path: '/welcome', builder: (_, __) => const Text('WELCOME')),
        GoRoute(path: '/splash', builder: (_, __) => const Text('SPLASH')),
        GoRoute(path: '/journal', builder: (_, __) => const Text('JOURNAL')),
        GoRoute(
          path: '/dish/:id',
          builder: (_, state) => Text('DISH ${state.pathParameters['id']}'),
        ),
        GoRoute(
          path: '/pantry',
          builder: (_, __) => const Text('PANTRY'),
          routes: [
            GoRoute(path: 'add', builder: (_, __) => const Text('PANTRY ADD')),
          ],
        ),
      ],
    );

Future<GoRouter> _pump(WidgetTester tester) async {
  final router = _testRouter();
  await tester.pumpWidget(MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  ));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  setUp(AppGate.reset);
  tearDown(AppGate.reset);

  testWidgets('an unknown route shows the in-app error, not the red screen',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final logs = <String>[];
    final debugPrintBefore = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) => logs.add(message ?? '');
    try {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          authReadyProvider.overrideWith((ref) async {}),
          databaseProvider.overrideWithValue(db),
          onboardingDoneProvider.overrideWith((ref) => true),
        ],
        child: const ShokuApp(),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      appRouter.go('/no-such-page');
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.routeErrorTitle), findsOneWidget);
      expect(find.text(l10n.routeErrorBody), findsOneWidget);
      // GoRouter's own page is the failure this screen exists to replace.
      expect(find.text('Page Not Found'), findsNothing);
      expect(
        logs.where((line) => line.contains('/no-such-page')),
        isNotEmpty,
        reason: 'a swallowed route failure is the bug this fixes',
      );

      await tester.tap(find.byKey(const ValueKey('route-error-back')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(l10n.routeErrorTitle), findsNothing);
      expect(find.byType(ShokuApp), findsOneWidget);

      // The shell schedules its three-second sync pass when it mounts.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpWidget(const SizedBox());
    } finally {
      debugPrint = debugPrintBefore;
    }
  });

  testWidgets('a destination attempted before onboarding is delivered after it',
      (tester) async {
    final router = await _pump(tester);

    // Not onboarded, no session: the gate takes the wheel, and the attempt is
    // kept rather than dropped.
    expect(find.text('WELCOME'), findsOneWidget);

    router.go('/dish/42');
    await tester.pumpAndSettle();
    expect(find.text('WELCOME'), findsOneWidget);
    expect(AppGate.destination, '/dish/42');

    // Onboarding finishes first; the session is still opening, so the splash
    // must not lose it either.
    AppGate.onboarded = true;
    router.refresh();
    await tester.pumpAndSettle();
    expect(find.text('SPLASH'), findsOneWidget);
    expect(AppGate.destination, '/dish/42');

    AppGate.authReady = true;
    router.refresh();
    await tester.pumpAndSettle();

    expect(find.text('DISH 42'), findsOneWidget,
        reason: 'the link pointed at the dish; the gate must land there');
    expect(AppGate.destination, isNull);
  });

  testWidgets('a branch deep link survives the gate too', (tester) async {
    final router = await _pump(tester);

    router.go('/pantry/add');
    await tester.pumpAndSettle();
    expect(find.text('WELCOME'), findsOneWidget);

    AppGate.onboarded = true;
    AppGate.authReady = true;
    router.refresh();
    await tester.pumpAndSettle();

    expect(find.text('PANTRY ADD'), findsOneWidget);
  });

  testWidgets('the destination is forgotten once it is delivered',
      (tester) async {
    final router = await _pump(tester);

    router.go('/dish/42');
    await tester.pumpAndSettle();
    AppGate.onboarded = true;
    AppGate.authReady = true;
    router.refresh();
    await tester.pumpAndSettle();
    expect(find.text('DISH 42'), findsOneWidget);

    // A second transition — the splash going up and coming back — must not
    // replay the link the user has already followed.
    AppGate.authReady = false;
    router.refresh();
    await tester.pumpAndSettle();
    expect(find.text('SPLASH'), findsOneWidget);

    AppGate.authReady = true;
    router.refresh();
    await tester.pumpAndSettle();

    expect(find.text('JOURNAL'), findsOneWidget);
    expect(find.text('DISH 42'), findsNothing);
  });

  testWidgets('the gate routes are never remembered', (tester) async {
    final router = await _pump(tester);

    // The boot attempt at the journal is a real path, so that one is kept.
    expect(AppGate.destination, '/journal');

    router.go('/splash?from=deep-link');
    await tester.pumpAndSettle();
    expect(find.text('WELCOME'), findsOneWidget);
    expect(AppGate.destination, '/journal',
        reason: 'storing the gate itself is how a redirect loops forever');

    AppGate.onboarded = true;
    AppGate.authReady = true;
    router.refresh();
    await tester.pumpAndSettle();

    expect(find.text('JOURNAL'), findsOneWidget);
  });
}
