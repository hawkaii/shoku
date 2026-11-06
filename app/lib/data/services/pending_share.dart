import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A share that arrived from another app and has not reached a screen yet.
///
/// A share is a one-shot event: Android hands the launching intent to one
/// process, once. Keeping it only in memory loses it whenever that process ends
/// before a sheet can open — and onboarding and the splash gate both keep the
/// shell off screen for a while. This is the note on disk that survives them,
/// including a force-stop.
class PendingShare {
  const PendingShare({required this.sharedAt, this.url});

  /// The first link found in the share.
  ///
  /// Null when the share carried none — an image, a video, a caption with no
  /// URL. That is still a share: the sheet opens with an explanation instead of
  /// nothing happening.
  final String? url;

  final DateTime sharedAt;

  bool get hasUrl => url != null && url!.isNotEmpty;

  Map<String, Object?> toJson() => {
        'url': url,
        'shared_at': sharedAt.toIso8601String(),
      };

  /// Null means unreadable, which the caller forgets. A share with no link is
  /// readable: it keeps its timestamp and its null [url].
  static PendingShare? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final sharedAt = DateTime.tryParse('${raw['shared_at']}');
    if (sharedAt == null) return null;
    final url = raw['url'];
    if (url is String) {
      return url.isEmpty
          ? PendingShare(sharedAt: sharedAt)
          : PendingShare(url: url, sharedAt: sharedAt);
    }
    if (url != null) return null;
    return PendingShare(sharedAt: sharedAt);
  }
}

/// Where [PendingShare] lives between a share and the sheet that opens it.
///
/// Mirrors `PendingImportStore`: one JSON string under one key, and a corrupt
/// note is forgotten rather than allowed to crash the launch.
class PendingShareStore {
  static const _key = 'share_pending';

  Future<PendingShare?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return PendingShare.fromJson(jsonDecode(raw));
    } catch (_) {
      // A corrupt note is not worth a crash; forget it.
      await prefs.remove(_key);
      return null;
    }
  }

  Future<void> write(PendingShare share) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(share.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Reads and clears in one step.
  ///
  /// This is how a share is consumed: the copy is gone before the sheet opens,
  /// so a second reader — a rebuild, a listener that fires twice, a relaunch
  /// mid-animation — finds nothing instead of opening the sheet again.
  Future<PendingShare?> take() async {
    final pending = await read();
    if (pending != null) await clear();
    return pending;
  }
}
