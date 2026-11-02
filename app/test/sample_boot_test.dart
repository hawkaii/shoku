import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/sample_recipe.dart';
import 'package:food_finder/main.dart';
import 'package:food_finder/presentation/state/auth_providers.dart';
import 'package:food_finder/presentation/screens/journal/journal_screen.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/presentation/state/shoku_providers.dart';

/// The release build's crash: a signed-out first launch, an empty database and
/// the sample seeded by the shell itself. These tests boot the real app and
/// render the journal with that sample, so a regression fails here — with a
/// readable stack — long before it reaches a build.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async => db.close());

  testWidgets('a signed-out first launch boots onto the sample',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        authReadyProvider.overrideWith((ref) async {}),
        databaseProvider.overrideWithValue(db),
        onboardingDoneProvider.overrideWith((ref) => true),
      ],
      child: const ShokuApp(),
    ));
    // The shell seeds the sample in a post-frame callback and starts a sync
    // timer at three seconds; give both room before judging the frame.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('pinned-card')), findsOneWidget);
    expect(find.text('Paneer Tikka'), findsWidgets);
    expect(find.text('SAMPLE'), findsWidgets);
  });

  test('the first read already has the sample — no second pass', () async {
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final states = <List<Dish>>[];
    container.listen<List<Dish>>(
      journalStoreProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // The immediate read, then exactly one load. If seeding happened after the
    // first load the journal would publish twice — an empty kitchen, then the
    // sample — which is the frame the crash report is about.
    expect(states, hasLength(2));
    expect(states.last, hasLength(1));
    expect(states.last.single.isSample, isTrue);
  });

  test('a reload reads the sample on its own first load', () async {
    await JournalRepository(db).seedSample(SampleRecipe.dish());

    // A fresh container is exactly what a reload creates: a new store over the
    // same database, with nobody calling ensureSample.
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final states = <List<Dish>>[];
    container.listen<List<Dish>>(
      journalStoreProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(states.last.single.isSample, isTrue);
  });

  testWidgets('the journal renders a sample dish with no cooks',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await JournalRepository(db).seedSample(SampleRecipe.dish());

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: JournalScreen()),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Paneer Tikka'), findsOneWidget);
    expect(find.text('SAMPLE'), findsOneWidget);
  });

  testWidgets('an empty journal is still a valid screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: JournalScreen()),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Save a recipe'), findsOneWidget);
  });

  testWidgets('a broken seed leaves the journal standing', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // A sample that cannot be written (the id column is required, and this
    // dish has no versions) must not take the shell with it.
    await JournalRepository(db).seedSample(
      SampleRecipe.dish().copyWith(versions: const []),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: JournalScreen()),
      ),
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
