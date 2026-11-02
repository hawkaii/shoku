import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/assistant_turn_repository.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/db/pantry_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/models/pantry_item.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/assistant_service.dart';
import 'package:food_finder/presentation/screens/bot/bot_scope.dart';
import 'package:food_finder/presentation/screens/bot/bot_surface.dart';
import 'package:food_finder/presentation/state/assistant_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:food_finder/presentation/state/sync_providers.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAssistant extends AssistantService {
  _FakeAssistant(this.reply)
      : super(
          api: ApiClient(
            baseUrl: 'https://api.test',
            tokenProvider: () => 'jwt',
            httpClient: MockClient((_) async => http.Response('{}', 200)),
          ),
        );

  final Future<AssistantReply> Function(String question, List<String> exclude)
      reply;
  final questions = <String>[];
  final excludes = <List<String>>[];

  @override
  Future<AssistantReply> ask({
    required String scope,
    String? dishId,
    String? versionId,
    int? stepIndex,
    required String question,
    required String requestId,
    List<AssistantTurn> history = const [],
    List<String> exclude = const [],
  }) {
    questions.add(question);
    excludes.add(exclude);
    return reply(question, exclude);
  }
}

Dish _dish(String id, String title) => Dish(
      id: id,
      title: title,
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@me',
      status: DishStatus.toCook,
      minutes: 20,
      steps: const ['Mix'],
      versions: [
        RecipeVersion(
          id: '$id-v1',
          number: 1,
          changes: const [],
          ingredients: const ['paneer'],
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      cooks: const [],
    );

AssistantReply _answer(String text) =>
    AssistantReply(intent: 'answer', answer: text, remaining: 9);

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    await JournalRepository(db).seed([
      _dish('d1', 'Paneer butter masala'),
      _dish('d2', 'Masala chai'),
    ]);
  });
  tearDown(() async => db.close());

  Widget sheet(AssistantService assistant, {List<Override> extra = const []}) =>
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          assistantServiceProvider.overrideWithValue(assistant),
          ...extra,
        ],
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: const Scaffold(body: BotSurface()),
        ),
      );

  Future<void> send(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const ValueKey('bot-input')), text);
    await tester.tap(find.byKey(const ValueKey('bot-send')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
  }

  group('threads', () {
    test('the kitchen and a dish keep their own turns', () async {
      final repo = AssistantTurnRepository(db);
      await repo.add(
        thread: const BotThread.kitchen(),
        versionId: null,
        role: 'user',
        text: 'what is for dinner?',
      );
      await repo.add(
        thread: const BotThread.dish('d1'),
        versionId: 'd1-v1',
        role: 'user',
        text: 'is this spicy?',
      );

      expect((await repo.loadThread(const BotThread.kitchen())).single.text,
          'what is for dinner?');
      expect((await repo.loadThread(const BotThread.dish('d1'))).single.text,
          'is this spicy?');
      expect(await repo.loadThread(const BotThread.dish('d2')), isEmpty);

      await repo.clearThread(const BotThread.kitchen());
      expect(await repo.loadThread(const BotThread.kitchen()), isEmpty);
      expect(await repo.loadThread(const BotThread.dish('d1')), hasLength(1),
          reason: 'clearing one thread never clears another');
    });

    testWidgets('scope labels say where you are', (tester) async {
      late String label;
      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Consumer(builder: (context, ref, _) {
            label = botScopeLabel(ref, const BotScope(dishId: 'd1'));
            return const SizedBox();
          }),
        ),
      ));
      await tester.pumpAndSettle();
      expect(label, 'Paneer butter masala');

      await tester.pumpWidget(ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Consumer(builder: (context, ref, _) {
            label = botScopeLabel(
                ref, const BotScope(dishId: 'd1', stepIndex: 2, stepCount: 7));
            return const SizedBox();
          }),
        ),
      ));
      await tester.pumpAndSettle();
      expect(label, 'Cooking · step 3 of 7');
    });
  });

  group('the kitchen thread', () {
    testWidgets('empty fridge offers three starters', (tester) async {
      await tester
          .pumpWidget(sheet(_FakeAssistant((_, __) async => _answer('ok'))));
      await tester.pumpAndSettle();

      expect(find.text("What's in your fridge?"), findsOneWidget);
      expect(find.text('Show me something from the Wall'), findsOneWidget);
      expect(find.text('I have a photo of a dish'), findsOneWidget);
    });

    testWidgets('a full fridge asks about dinner instead', (tester) async {
      await PantryRepository(db)
          .add(name: 'rice', quantity: 2, unit: PantryUnit.kg);
      await PantryRepository(db)
          .add(name: 'paneer', quantity: 200, unit: PantryUnit.g);

      await tester
          .pumpWidget(sheet(_FakeAssistant((_, __) async => _answer('ok'))));
      await tester.pumpAndSettle();

      expect(
        find.text('You have 2 things in the fridge. Dinner from them?'),
        findsOneWidget,
      );
    });

    testWidgets('suggestions render as cards, and Not this reshuffles',
        (tester) async {
      final cards = [
        const BotSuggestion(
            shortcode: 'A',
            title: 'Paneer Tikka',
            creator: 'ravi',
            have: 4,
            total: 6,
            missing: ['lime', 'chilli']),
        const BotSuggestion(
            shortcode: 'B', title: 'Egg curry', have: 3, total: 5),
        const BotSuggestion(
            shortcode: 'C', title: 'Tomato rice', have: 2, total: 4),
      ];
      final assistant = _FakeAssistant((question, exclude) async =>
          AssistantReply(
              intent: 'suggest',
              answer: 'Try one of these.',
              remaining: 8,
              suggestions: cards));

      await tester.pumpWidget(sheet(assistant));
      await tester.pumpAndSettle();
      await send(tester, 'Dinner from my fridge?');

      expect(find.byKey(const ValueKey('bot-suggestions')), findsOneWidget);
      expect(find.byKey(const ValueKey('bot-card-A')), findsOneWidget);
      expect(find.byKey(const ValueKey('bot-card-B')), findsOneWidget);
      expect(find.byKey(const ValueKey('bot-card-C')), findsOneWidget);
      expect(find.textContaining('Wall · @ravi'), findsOneWidget);
      expect(find.text('LIME'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('bot-card-not-this-A')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(assistant.excludes.last, containsAll(['A', 'B', 'C']),
          reason: 'the cards already seen are excluded from the reshuffle');
    });

    testWidgets('a capture card writes nothing until it is confirmed',
        (tester) async {
      final assistant = _FakeAssistant((_, __) async => const AssistantReply(
            intent: 'capture',
            answer: 'I read two things.',
            remaining: 8,
            items: [
              BotCaptureItem(name: 'rice', quantity: 2, unit: 'kg'),
              BotCaptureItem(name: 'paneer'),
            ],
          ));

      await tester.pumpWidget(sheet(assistant));
      await tester.pumpAndSettle();
      await send(tester, 'I have 2 kg rice and paneer');

      expect(find.byKey(const ValueKey('bot-capture-card')), findsOneWidget);
      expect(find.text('rice · 2 kg'), findsOneWidget);
      expect(find.text('paneer · amount?'), findsOneWidget);
      expect(await PantryRepository(db).load(), isEmpty,
          reason: 'no silent writes from chat');

      await tester.tap(find.text('Add 2 items to fridge'));
      await tester.pumpAndSettle();

      final rows = await PantryRepository(db).load();
      expect([for (final r in rows) r.name], containsAll(['rice', 'paneer']));
    });

    testWidgets('offline says so and closes the composer', (tester) async {
      await tester.pumpWidget(sheet(
        _FakeAssistant((_, __) async => _answer('ok')),
        extra: [syncStatusProvider.overrideWith((ref) => SyncStatus.offline)],
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('bot-offline')), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('bot-input')))
            .enabled,
        isFalse,
      );
    });

    testWidgets('the cap is a sentence, and leaves the rest standing',
        (tester) async {
      final assistant =
          _FakeAssistant((_, __) async => throw const AssistantCapReached());
      await tester.pumpWidget(sheet(assistant));
      await tester.pumpAndSettle();
      await send(tester, 'one more?');

      expect(
          find.text(
              'You have used today’s questions. They come back tomorrow.'),
          findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('bot-input')))
            .enabled,
        isFalse,
      );
    });

    testWidgets('a wrong context offers the dishes as a question',
        (tester) async {
      final assistant = _FakeAssistant((_, __) async => const AssistantReply(
            intent: 'clarify',
            answer: 'Which dish?',
            remaining: 9,
            choices: [
              BotChoice(dishId: 'd1', title: 'Paneer butter masala'),
              BotChoice(dishId: 'd2', title: 'Masala chai'),
            ],
          ));
      await tester.pumpWidget(sheet(assistant));
      await tester.pumpAndSettle();
      await send(tester, 'add potato');

      expect(find.textContaining('Paneer butter masala'), findsOneWidget);
      expect(find.byKey(const ValueKey('bot-choices')), findsOneWidget);
    });
  });

  group('scope', () {
    testWidgets('the switcher lists this dish, recent dishes and no dish',
        (tester) async {
      await tester
          .pumpWidget(sheet(_FakeAssistant((_, __) async => _answer('ok'))));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('bot-scope-chip')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('bot-scope-switcher')), findsOneWidget);
      expect(find.byKey(const ValueKey('bot-scope-dish-d1')), findsOneWidget);
      expect(find.byKey(const ValueKey('bot-scope-dish-d2')), findsOneWidget);
      expect(find.byKey(const ValueKey('bot-scope-kitchen')), findsOneWidget);
    });

    testWidgets('picking a dish moves the conversation to its thread',
        (tester) async {
      await tester
          .pumpWidget(sheet(_FakeAssistant((_, __) async => _answer('ok'))));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('bot-scope-chip')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bot-scope-dish-d1')));
      await tester.pumpAndSettle();

      // The dish sheet, with the dish's own thread and its scope chip.
      expect(find.textContaining('Ask about this dish'), findsOneWidget);
      expect(find.byKey(const ValueKey('bot-scope-chip')), findsWidgets);
    });
  });
}
