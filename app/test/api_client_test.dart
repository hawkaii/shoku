import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:food_finder/data/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('attaches the Supabase token as a bearer header', () async {
    late Map<String, String> sent;
    final client = ApiClient(
      baseUrl: 'https://api.test',
      tokenProvider: () => 'jwt-123',
      httpClient: MockClient((request) async {
        sent = request.headers;
        return http.Response(jsonEncode({'dishes': []}), 200);
      }),
    );

    await client.syncPull();

    expect(sent['authorization'], 'Bearer jwt-123');
    expect(sent['content-type'], contains('application/json'));
  });

  test('sends no authorization header when signed out', () async {
    late Map<String, String> sent;
    final client = ApiClient(
      baseUrl: 'https://api.test',
      tokenProvider: () => null,
      httpClient: MockClient((request) async {
        sent = request.headers;
        return http.Response(jsonEncode({'dishes': []}), 200);
      }),
    );

    await client.syncPull();

    expect(sent.containsKey('authorization'), isFalse);
  });

  test('a 401 becomes ApiUnauthenticated, not a generic error', () async {
    final client = ApiClient(
      baseUrl: 'https://api.test',
      tokenProvider: () => 'expired',
      httpClient: MockClient((_) async => http.Response('{}', 401)),
    );

    await expectLater(client.syncPull(), throwsA(isA<ApiUnauthenticated>()));
  });

  test('a 4xx carries the server reason', () async {
    final client = ApiClient(
      baseUrl: 'https://api.test',
      tokenProvider: () => 'jwt',
      httpClient: MockClient(
        (_) async => http.Response(jsonEncode({'error': 'unsupported_url'}), 422),
      ),
    );

    await expectLater(
      client.post('/v1/imports', {'url': 'nope'}),
      throwsA(isA<ApiError>().having((e) => e.reason, 'reason', 'unsupported_url')),
    );
  });
}
