import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// An import that the server is still working on.
///
/// The sheet is a view over a job that lives on the server, so closing the sheet
/// — or the app dying — must not end the import. This is the note kept on the
/// phone that says "there is something in flight, go and look".
class PendingImport {
  const PendingImport({
    required this.url,
    required this.shortcode,
    required this.startedAt,
    this.jobId,
  });

  final String url;
  final String shortcode;

  /// Null when the parse was already cached and the server never made a job.
  final String? jobId;

  final DateTime startedAt;

  bool get hasJob => jobId != null;

  Map<String, Object?> toJson() => {
        'url': url,
        'shortcode': shortcode,
        'job_id': jobId,
        'started_at': startedAt.toIso8601String(),
      };

  static PendingImport? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final url = raw['url'];
    final started = DateTime.tryParse('${raw['started_at']}');
    if (url is! String || url.isEmpty || started == null) return null;
    return PendingImport(
      url: url,
      shortcode: (raw['shortcode'] as String?) ?? '',
      jobId: raw['job_id'] as String?,
      startedAt: started,
    );
  }
}

/// Where [PendingImport] lives between launches.
class PendingImportStore {
  static const _key = 'import_pending';

  Future<PendingImport?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return PendingImport.fromJson(jsonDecode(raw));
    } catch (_) {
      // A corrupt note is not worth a crash; forget it.
      await prefs.remove(_key);
      return null;
    }
  }

  Future<void> write(PendingImport pending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(pending.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
