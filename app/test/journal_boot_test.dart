import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/sample_recipe.dart';
import 'package:food_finder/presentation/screens/journal/journal_screen.dart';
import 'package:food_finder/presentation/state/journal_store.dart';

/// The bug the owner saw: a Journal built while the store was empty, then a
/// dish arrived and the page never repainted. These tests build the Journal
/// *before* the rows exist, which the older ones did not.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Widget journal(ProviderContainer container) => UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: const Scaffold(body: JournalScreen()),
        ),
      );

  testWidgets('a dish that arrives after the first build reaches the Journal',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        // No starter dish: the store boots over an empty table, exactly like
        // the frame the owner was looking at.
        sampleRecipeProvider.overrideWithValue(null),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(journal(container));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('pinned-card')), findsNothing);
    expect(find.text('Paneer Tikka'), findsNothing);

    // The row lands after the first build (the shell's catch-up read does this
    // for real; a warm sync or a second boot can too).
    await JournalRepository(db).seedSample(SampleRecipe.dish());
    await container.read(journalStoreProvider.notifier).reload();
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('pinned-card')), findsOneWidget,
        reason: 'the Journal has to repaint from the store, not keep its first '
            'empty branch');
    expect(find.text('Paneer Tikka'), findsOneWidget);
    expect(find.text('SAMPLE'), findsOneWidget);
  });
}
