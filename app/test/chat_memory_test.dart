import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
import 'package:food_finder/data/db/assistant_turn_repository.dart';
import 'package:food_finder/data/db/journal_repository.dart';
import 'package:food_finder/data/mock/journal_data.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/assistant_service.dart';
import 'package:food_finder/presentation/screens/assistant/recipe_chat_sheet.dart';
import 'package:food_finder/presentation/state/assistant_providers.dart';
import 'package:food_finder/presentation/state/journal_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAssistant extends AssistantService {
  _FakeAssistant(this._reply)
      : super(
          api: ApiClient(
            baseUrl: 'https://api.test',
            tokenProvider: () => 'jwt',
            httpClient: MockClient((_) async => http.Response('{}', 200)),
          ),
        );

  final Future<AssistantReply> Function() _reply;
  final history = <List<AssistantTurn>>[];
  final versionIds = <String?>[];

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
    this.history.add(history);
    versionIds.add(versionId);
    return _reply();
  }
}

AssistantReply _answer(String text) =>
    AssistantReply(intent: 'answer', answer: text, remaining: 9);

Dish _dish({int versions = 1}) => Dish(
      id: 'd1',
      title: 'Paneer',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.cooked,
      minutes: 20,
      steps: const ['Fry the paneer'],
      versions: [
        for (var v = 1; v <= versions; v++)
          RecipeVersion(
            id: 'v$v',
            number: v,
            changes: v == 1 ? const [] : const ['More salt'],
            ingredients: const ['200 g paneer', '2 tbsp oil'],
            createdAt: DateTime(2026, 1, v),
            steps: const ['Fry the paneer'],
          ),
      ],
      cooks: const [],
    );

void main() {
  late AppDatabase db;
  late AssistantTurnRepository turns;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    turns = AssistantTurnRepository(db);
    SharedPreferences.setMockInitialValues({});
    await JournalRepository(db).seed([_dish(versions: 2)]);
  });
  tearDown(() async => db.close());

  Widget chat(AssistantService service, {Dish? dish}) => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          assistantServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: Scaffold(body: RecipeChatSheet(dish: dish ?? _dish(versions: 2))),
        ),
      );

  Future<void> send(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.byKey(const ValueKey('chat-send')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('memory', () {
    test('the last twenty come back, oldest first, and clear empties them',
        () async {
      for (var i = 0; i < 25; i++) {
        await turns.add(
          dishId: 'd1',
          versionId: 'v1',
          role: i.isEven ? 'user' : 'assistant',
          text: 'turn $i',
          now: DateTime(2026, 1, 1, 0, i),
        );
      }

      expect(await turns.count('d1'), 25);
      final last = await turns.load('d1');
      expect(last, hasLength(20));
      expect(last.first.text, 'turn 5', reason: 'the oldest of the last twenty');
      expect(last.last.text, 'turn 24', reason: 'newest last');
      expect((await turns.load('d1', limit: 100)), hasLength(25));

      await turns.clear('d1');
      expect(await turns.count('d1'), 0);
    });

    testWidgets('the sheet restores what this device already said',
        (tester) async {
      await turns.add(
          dishId: 'd1', versionId: 'v2', role: 'user', text: 'is this spicy?');
      await turns.add(
          dishId: 'd1', versionId: 'v2', role: 'assistant', text: 'Mildly.');

      await tester.pumpWidget(chat(_FakeAssistant(() async => _answer('ok'))));
      await tester.pumpAndSettle();

      expect(find.text('is this spicy?'), findsOneWidget);
      expect(find.text('Mildly.'), findsOneWidget);
    });

    testWidgets('earlier turns sit behind Show earlier (N)', (tester) async {
      for (var i = 0; i < 25; i++) {
        await turns.add(
          dishId: 'd1',
          versionId: 'v2',
          role: 'user',
          text: 'turn $i',
          now: DateTime(2026, 1, 1, 0, i),
        );
      }

      await tester.pumpWidget(chat(_FakeAssistant(() async => _answer('ok'))));
      await tester.pumpAndSettle();

      expect(find.text('Show earlier (5)'), findsOneWidget);
      expect(find.text('turn 0'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('chat-earlier')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('chat-earlier')), findsNothing,
          reason: 'everything this dish ever said is now loaded');
    });

    testWidgets('the header says the version, and clears on request',
        (tester) async {
      await turns.add(
          dishId: 'd1', versionId: 'v2', role: 'user', text: 'remember me');

      await tester.pumpWidget(chat(_FakeAssistant(() async => _answer('ok'))));
      await tester.pumpAndSettle();

      expect(find.text('Ask about this dish · v2'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('chat-clear')));
      await tester.pumpAndSettle();

      expect(find.text('remember me'), findsNothing);
      expect(await turns.count('d1'), 0);
    });
  });

  group('versions', () {
    testWidgets('history only carries turns from the version on screen',
        (tester) async {
      await turns.add(
          dishId: 'd1', versionId: 'v1', role: 'user', text: 'old question');
      await turns.add(
          dishId: 'd1', versionId: 'v1', role: 'assistant', text: 'old answer');
      await turns.add(
          dishId: 'd1', versionId: 'v2', role: 'user', text: 'new question');
      await turns.add(
          dishId: 'd1', versionId: 'v2', role: 'assistant', text: 'new answer');

      final assistant = _FakeAssistant(() async => _answer('ok'));
      await tester.pumpWidget(chat(assistant));
      await tester.pumpAndSettle();

      await send(tester, 'does it need salt?');

      expect(assistant.history.single.map((t) => t.text).toList(),
          ['new question', 'new answer'],
          reason: 'v1 is a different recipe; its answers are not context');
    });

    testWidgets('a new version is a divider, and the sent turns are persisted',
        (tester) async {
      final assistant = _FakeAssistant(() async => _answer('Mildly.'));
      await tester.pumpWidget(chat(assistant));
      await tester.pumpAndSettle();

      await send(tester, 'is this spicy?');
      await tester.pumpAndSettle();

      final saved = await turns.load('d1');
      expect(saved.map((t) => '${t.role}:${t.text}').toList(),
          ['user:is this spicy?', 'assistant:Mildly.']);
      expect(saved.every((t) => t.versionId == 'v2'), isTrue);

      // Move the head the way a chat edit does: the sheet notices and starts a
      // new context behind a divider.
      final store = ProviderScope.containerOf(
        tester.element(find.byType(RecipeChatSheet)),
      ).read(journalStoreProvider.notifier);
      await store.applyEditVersion(
        dishId: 'd1',
        baseVersionId: 'v2',
        ingredients: const ['200 g paneer'],
        steps: const ['Fry'],
        stepIngredients: const [],
        changes: const ['Less oil'],
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('chat-version-divider')), findsOneWidget);
    });
  });
}
