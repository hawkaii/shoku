import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drift/native.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/main.dart';
import 'package:food_finder/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:food_finder/presentation/screens/splash_screen.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/presentation/state/shoku_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_finder/presentation/state/auth_providers.dart';

void main() {
  testWidgets('Shoku boots into onboarding', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [authReadyProvider.overrideWith((ref) async {})],
      child: const ShokuApp(),
    ));
    await tester.pump(const Duration(milliseconds: 400));

    // The language step is first now, so the stable signal is the route plus
    // its localized title, not a button label that moved one page in.
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    // The splash paints first, so onboarding mounts on this frame and its
    // entrance timer is still queued: one more pump lets it fire, and tearing
    // the tree down afterwards cancels anything it left.
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('auth resolving while onboarding is up never rebuilds the app',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final gate = Completer<void>();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authReadyProvider.overrideWith((ref) => gate.future),
        databaseProvider.overrideWithValue(db),
      ],
      child: const ShokuApp(),
    ));
    await tester.pumpAndSettle();

    // Onboarding is local, so it is the first screen; the session opens behind
    // it. No second MaterialApp is swapped in when it resolves.
    expect(find.byType(OnboardingScreen), findsOneWidget);
    gate.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an onboarded first frame is the splash, then the router',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final gate = Completer<void>();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authReadyProvider.overrideWith((ref) => gate.future),
        onboardingDoneProvider.overrideWith((ref) => true),
        databaseProvider.overrideWithValue(db),
      ],
      child: const ShokuApp(),
    ));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget,
        reason: 'something is painted while the session opens');
    expect(find.byType(OnboardingScreen), findsNothing);

    gate.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Save a recipe'), findsOneWidget,
        reason: 'the router took over from the splash without a rebuild of the app');

    // The shell schedules its three-second sync pass when it mounts.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox());
  });
}
