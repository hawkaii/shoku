import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/presentation/screens/journal/journal_screen.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/import_service.dart';
import 'package:food_finder/data/services/pending_import.dart';
import 'package:food_finder/presentation/state/import_providers.dart';
import 'package:food_finder/presentation/state/journal_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Dish _dish({CookMood mood = CookMood.comfort, int rating = 4}) => Dish(
      id: 'd1',
      title: 'Paneer Tikka',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.cooked,
      minutes: 20,
      steps: const ['Fry'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const [],
          ingredients: const ['paneer'],
          createdAt: DateTime(2026, 10, 30),
        ),
      ],
      cooks: [
        CookLog(
          id: 'c1',
          cookedAt: DateTime(2026, 10, 30, 20, 15),
          versionNumber: 1,
          versionId: 'v1',
          photoUrl: '',
          outcome: CookOutcome.good,
          note: '',
          changes: const [],
          mood: mood,
          rating: rating,
        ),
      ],
    );

void main() {
  setUp(() {
    // Each test starts with no import in flight.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('a cook entry shows the mood and the rating, quietly',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [dishesProvider.overrideWithValue([_dish()])],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: JournalScreen()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('cook-mood-rating')), findsOneWidget);
    expect(find.text('comfort · 4/5'), findsOneWidget);

    final text = tester.widget<Text>(
      find.byKey(const ValueKey('cook-mood-rating')),
    );
    final context = tester.element(
      find.byKey(const ValueKey('cook-mood-rating')),
    );
    expect(text.style?.color, context.colors.inkMuted);
    expect(text.style?.fontSize, ShokuType.bodySmall.fontSize);
  });

  testWidgets('an empty journal still shows the import that is running',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await PendingImportStore().write(PendingImport(
      url: 'https://instagram.com/reel/ABC123/',
      shortcode: 'ABC123',
      jobId: 'job1',
      startedAt: DateTime(2026, 10, 31, 6, 20),
    ));

    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'job_id': 'job1',
          'state': 'extracting',
          'shortcode': 'ABC123',
          'reason': null,
          'progress_stage': 'starting',
          'title': null,
        }),
        200,
      );
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dishesProvider.overrideWithValue(const []),
        journalStatusProvider.overrideWith((ref) => JournalStatus.ready),
        importServiceProvider.overrideWithValue(ImportService(
          api: ApiClient(
            baseUrl: 'https://api.test',
            tokenProvider: () => 'jwt',
            httpClient: client,
          ),
          repository: JournalRepository(db),
        )),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: JournalScreen()),
      ),
    ));
    await tester.pump();
    await tester.pump();

    // The card is on screen even with nothing in the journal, and the empty
    // journal is still underneath it rather than hidden behind it.
    expect(find.text('Waking the kitchen…'), findsOneWidget);
    expect(find.text('No dishes yet — import a reel to start'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    // Let anything the last poll scheduled drain before the test ends.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('the words follow the log, not a default', (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        dishesProvider
            .overrideWithValue([_dish(mood: CookMood.project, rating: 2)]),
      ],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const Scaffold(body: JournalScreen()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('project · 2/5'), findsOneWidget);
  });
}
