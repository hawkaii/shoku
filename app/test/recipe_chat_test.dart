import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/core/theme/shoku_theme.dart';
import 'package:food_finder/data/db/app_database.dart';
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

  @override
  Future<AssistantReply> ask({
    required String dishId,
    String? versionId,
    required String question,
    required String requestId,
    List<AssistantTurn> history = const [],
  }) =>
      _reply();
}

Dish _dish() => Dish(
      id: 'd1',
      title: 'Paneer',
      subtitle: '',
      coverUrl: '',
      sourceHandle: '@ravi',
      status: DishStatus.cooked,
      minutes: 20,
      steps: const ['Fry the paneer'],
      versions: [
        RecipeVersion(
          id: 'v1',
          number: 1,
          changes: const ['First'],
          ingredients: const ['200 g paneer'],
          createdAt: DateTime(2026, 1, 1),
          steps: const ['Fry the paneer'],
        ),
      ],
      cooks: const [],
    );

AssistantReply _edit({String base = 'v1'}) => AssistantReply(
      intent: 'edit',
      answer: 'Added 2 potatoes.',
      remaining: 18,
      edits: const [
        AssistantEdit(op: 'add', index: 1, text: '2 potatoes, cubed'),
      ],
      appliable: AssistantAppliable(
        ingredients: const ['200 g paneer', '2 potatoes, cubed'],
        steps: const ['Fry the paneer', 'Boil the potatoes'],
        stepIngredients: const [
          [0],
          [1],
        ],
        changes: const ['Added 2 potatoes'],
        baseVersionId: base,
      ),
    );

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    await JournalRepository(db).seed([_dish()]);
  });
  tearDown(() async => db.close());

  Widget chat(AssistantService service) => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          assistantServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          theme: ShokuTheme.light(),
          home: Scaffold(body: RecipeChatSheet(dish: _dish())),
        ),
      );

  Future<void> send(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.tap(find.byKey(const ValueKey('chat-send')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('offline is a notice, and the composer closes', (tester) async {
    await tester.pumpWidget(chat(_FakeAssistant(() async => throw Exception('down'))));
    await send(tester, 'is this done?');

    expect(find.text('No connection — answers need the network.'), findsOneWidget);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse, reason: 'nothing typed can be sent');
    expect(find.text('No connection'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the cap is its own sentence, not an error', (tester) async {
    await tester.pumpWidget(chat(_FakeAssistant(
      () async => throw const AssistantCapReached(),
    )));
    await send(tester, 'one more?');

    expect(
      find.text('You have used today’s questions. They come back tomorrow.'),
      findsOneWidget,
    );
    expect(find.text('Out of questions for today'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an edit renders its diff and blocks the composer', (tester) async {
    await tester.pumpWidget(chat(_FakeAssistant(() async => _edit())));
    await send(tester, 'add potatoes');

    expect(find.byKey(const ValueKey('recipe-diff')), findsOneWidget);
    expect(find.text('RECIPE CHANGE'), findsOneWidget);
    expect(find.text('v1 → v2'), findsOneWidget);
    expect(find.text('2 potatoes, cubed'), findsOneWidget);
    expect(find.text('Resolve the change above'), findsOneWidget);
    expect(find.byKey(const ValueKey('diff-apply')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a stale base offers Recompute and writes nothing', (tester) async {
    await tester.pumpWidget(
      chat(_FakeAssistant(() async => _edit(base: 'a-version-we-lost'))),
    );
    await send(tester, 'add potatoes');

    await tester.tap(find.byKey(const ValueKey('diff-apply')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byKey(const ValueKey('diff-recompute')), findsOneWidget);
    expect(find.text('Recompute'), findsOneWidget);

    final dish = (await JournalRepository(db).loadDishes()).single;
    expect(dish.versions, hasLength(1),
        reason: 'arrays computed against a lost version are never written');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('applying a fresh edit writes one version and says so',
      (tester) async {
    await tester.pumpWidget(chat(_FakeAssistant(() async => _edit())));
    await send(tester, 'add potatoes');

    await tester.tap(find.byKey(const ValueKey('diff-apply')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('chat-applied')), findsOneWidget);
    final dish = (await JournalRepository(db).loadDishes()).single;
    expect(dish.versions, hasLength(2));
    expect(dish.versions.last.parentVersionId, 'v1');
    expect(dish.cooks, isEmpty);

    await tester.pumpWidget(const SizedBox());
  });
}
