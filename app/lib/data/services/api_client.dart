import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/shoku_config.dart';
import 'auth_service.dart';

/// The only way the app reaches our API.
///
/// Every request carries the Supabase access token; the server verifies it
/// against the project's JWKS and takes the `sub` claim as the owner. A 401 is
/// reported as [ApiUnauthenticated] so callers can prompt a sign-in instead of
/// showing a generic failure.
class ApiClient {
  ApiClient({
    AuthService? auth,
    http.Client? httpClient,
    String? baseUrl,
    String? Function()? tokenProvider,
  })  : _http = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ShokuConfig.apiBaseUrl,
        _token = tokenProvider ?? (() => (auth ?? AuthService()).accessToken);

  /// Injected so tests never touch the Supabase singleton.
  final String? Function() _token;
  final http.Client _http;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> _headers() {
    final token = _token();
    return {
      'content-type': 'application/json',
      if (token != null) 'authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String path) async =>
      _decode(await _http.get(_uri(path), headers: _headers()));

  Future<Map<String, dynamic>> post(String path, [Object? body]) async =>
      _decode(await _http.post(
        _uri(path),
        headers: _headers(),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ));

  Future<Map<String, dynamic>> delete(String path) async =>
      _decode(await _http.delete(_uri(path), headers: _headers()));

  Future<Map<String, dynamic>> put(String path, [Object? body]) async =>
      _decode(await _http.put(
        _uri(path),
        headers: _headers(),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ));

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode == 401) {
      throw const ApiUnauthenticated();
    }
    if (response.statusCode >= 400) {
      String reason = 'http_${response.statusCode}';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['error'] is String) {
          reason = decoded['error'] as String;
        }
      } catch (_) {
        // Body wasn't JSON; the status code is the best we have.
      }
      throw ApiError(reason, response.statusCode);
    }
    if (response.body.isEmpty) return const {};
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
  }

  /// Push rows the local database has marked dirty, and pull what changed.
  /// Implemented by the sync engine; kept here so there is one HTTP surface.
  Future<Map<String, dynamic>> syncPush(Map<String, dynamic> payload) =>
      post('/v1/sync/push', payload);

  Future<Map<String, dynamic>> syncPull({String? since, String? cursor}) =>
      post('/v1/sync/pull', {
        if (since != null) 'since': since,
        if (cursor != null) 'cursor': cursor,
      });
}

class ApiUnauthenticated implements Exception {
  const ApiUnauthenticated();
  @override
  String toString() => 'not signed in';
}

class ApiError implements Exception {
  ApiError(this.reason, this.status);

  final String reason;
  final int status;

  @override
  String toString() => 'ApiError($status, $reason)';
}
