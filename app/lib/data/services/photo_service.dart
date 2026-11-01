import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_client.dart';

/// A photo that has been uploaded and is ready to travel on the sync wire.
class UploadedPhoto {
  const UploadedPhoto({required this.key, this.url});

  /// The object key the API owns, e.g. `photos/<uid>/<yyyymm>/<rand>.jpg`.
  final String key;

  /// A URL to show it now, when the presign response offers one.
  final String? url;
}

/// Presigned direct upload. The image bytes never touch the API process: the
/// API hands back a URL, and the file goes straight to the bucket.
class PhotoService {
  PhotoService({required ApiClient api, http.Client? client})
      : _api = api,
        _client = client ?? http.Client();

  final ApiClient _api;
  final http.Client _client;

  Future<UploadedPhoto> upload(
    File file, {
    String role = 'debrief',
    String contentType = 'image/jpeg',
  }) async {
    final bytes = await file.readAsBytes();
    final presign = await _api.post('/v1/photos/presign', {
      'role': role,
      'content_type': contentType,
      'size': bytes.length,
    });

    final key = presign['key'] as String?;
    final uploadUrl = (presign['upload_url'] ?? presign['url']) as String?;
    if (key == null || key.isEmpty || uploadUrl == null || uploadUrl.isEmpty) {
      throw ApiError('presign_missing', 500);
    }

    final response = await _client.put(
      Uri.parse(uploadUrl),
      headers: {'content-type': contentType},
      body: bytes,
    );
    if (response.statusCode >= 400) {
      throw ApiError('upload_failed', response.statusCode);
    }

    return UploadedPhoto(
      key: key,
      url: presign['public_url'] as String? ?? presign['read_url'] as String?,
    );
  }

  /// The wire row a photo travels as (contract §Photos). One per cook.
  static Map<String, dynamic> wireRow({
    required String id,
    required String key,
    String role = 'debrief',
    String? cookId,
    String? versionId,
    required DateTime createdAt,
  }) =>
      {
        'id': id,
        'role': role,
        if (versionId != null) 'version_id': versionId,
        if (cookId != null) 'cook_id': cookId,
        'key': key,
        'created_at': createdAt.toUtc().toIso8601String(),
        'deleted_at': null,
      };

  static String encode(Object? value) => jsonEncode(value ?? const <String>[]);
}
