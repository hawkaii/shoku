import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:food_finder/data/services/assistant_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

AssistantService _service(http.Client client) => AssistantService(
      api: ApiClient(
        baseUrl: 'https://api.test',
        tokenProvider: () => 'jwt',
        httpClient: client,
      ),
    );

void main() {
  test('an answer carries its text, remaining and reset date', () async {
    late Map<String, dynamic> body;
    final service = _service(MockClient((request) async {
      body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'intent': 'answer',
          'answer': '2 tbsp is about 30 ml.',
          'remaining': 19,
          'reset_at': '2026-11-03T00:00:00Z',
        }),
        200,
      );
    }));

    final reply = await service.ask(
      scope: 'dish',
      dishId: 'd1',
      versionId: 'v1',
      question: 'how much is 2 tbsp?',
      requestId: 'r1',
    );

    expect(reply.intent, 'answer');
    expect(reply.answer, '2 tbsp is about 30 ml.');
    expect(reply.remaining, 19);
    expect(reply.resetAt, isNotNull);
    expect(reply.isEdit, isFalse);
    expect(body['dish_id'], 'd1');
    expect(body['version_id'], 'v1');
    expect(body['request_id'], 'r1');
    expect(body.containsKey('history'), isFalse);
  });

  test('an edit parses its diff and the arrays to apply', () async {
    final service = _service(MockClient((request) async {
      return http.Response(
        jsonEncode({
          'intent': 'edit',
          'answer': 'Added 2 potatoes.',
          'remaining': 18,
          'reset_at': '2026-11-03T00:00:00Z',
          'edits': [
            {'op': 'add', 'index': 5, 'text': '2 potatoes, cubed', 'previous': null},
            {
              'op': 'change',
              'index': 3,
              'text': 'Boil the potatoes until tender.',
              'previous': 'Boil the kettle.',
            },
          ],
          'appliable': {
            'ingredients': ['200 g paneer', '2 potatoes, cubed'],
            'steps': ['Fry', 'Boil the potatoes until tender.'],
            'step_ingredients': [
              [0],
              [1],
            ],
            'changes': ['Added 2 potatoes'],
            'base_version_id': 'v9',
          },
        }),
        200,
      );
    }));

    final reply = await service.ask(
      scope: 'dish',
      dishId: 'd1',
      question: 'add potatoes',
      requestId: 'r2',
    );

    expect(reply.isEdit, isTrue);
    expect(reply.edits, hasLength(2));
    expect(reply.edits.first.op, 'add');
    expect(reply.edits.last.previous, 'Boil the kettle.');
    expect(reply.appliable!.baseVersionId, 'v9');
    expect(reply.appliable!.steps.last, 'Boil the potatoes until tender.');
    expect(reply.appliable!.stepIngredients, [
      [0],
      [1],
    ]);
    expect(reply.appliable!.changes, ['Added 2 potatoes']);
  });

  test('history is echoed, at most two exchanges', () async {
    late Map<String, dynamic> body;
    final service = _service(MockClient((request) async {
      body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({'intent': 'answer', 'answer': 'ok', 'remaining': 1}),
        200,
      );
    }));

    await service.ask(
      scope: 'dish',
      dishId: 'd1',
      question: 'and then?',
      requestId: 'r3',
      history: const [
        AssistantTurn(role: 'user', text: 'q1'),
        AssistantTurn(role: 'assistant', text: 'a1'),
      ],
    );

    final history = body['history'] as List;
    expect(history, hasLength(2));
    expect((history.first as Map)['role'], 'user');
  });

  test('the daily cap is a state, not a network error', () async {
    final service = _service(MockClient((request) async {
      return http.Response(
        jsonEncode({'error': 'daily_cap_reached', 'reset_at': '2026-11-03T00:00:00Z'}),
        429,
      );
    }));

    await expectLater(
      service.ask(scope: 'dish', dishId: 'd1', question: 'anything', requestId: 'r4'),
      throwsA(isA<AssistantCapReached>()),
    );
  });
}
