import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/services/speech_service.dart';
import 'package:food_finder/presentation/screens/assistant/recipe_chat_sheet.dart';
import 'package:food_finder/presentation/screens/dish/dish_screen.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Dish _dish() => Dish(
      id: 'd1',
      title: 'Paneer Tikka',
      subtitle: 'From Ravi',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.toCook,
      minutes: 22,
      steps: const ['Heat the oil', 'Add the paneer'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const [],
          ingredients: const ['400 g paneer'],
          createdAt: DateTime(2026, 1, 1),
          steps: const ['Heat the oil', 'Add the paneer'],
        ),
      ],
      cooks: const [],
    );

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await JournalRepository(db).seed([_dish()]);
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async => db.close());

  test('read-aloud is off until somebody turns it on, per device', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(readAloudProvider), isFalse,
        reason: 'an app that starts talking in a kitchen is one you turn off');

    await container.read(readAloudProvider.notifier).toggle();
    expect(container.read(readAloudProvider), isTrue);
    expect(
      (await SharedPreferences.getInstance()).getBool('read_aloud'),
      isTrue,
    );
  });

  testWidgets('the page carries the speaker, header and per step',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: const DishScreen(dishId: 'd1'),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dish-speak')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('steps-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('step-speak-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('step-speak-1')), findsOneWidget);
  });

  testWidgets('the chat sheet has no read-aloud toggle any more',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        theme: ShokuTheme.light(),
        home: Scaffold(body: RecipeChatSheet(dish: _dish())),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('read-aloud-toggle')), findsNothing);
    expect(find.text('Read aloud'), findsNothing);
    expect(find.byKey(const ValueKey('bot-new-chat')), findsOneWidget);
  });
}
