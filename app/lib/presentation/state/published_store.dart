import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The shortcodes this device has published to the Wall.
///
/// The API has no "is this shared?" read — the feed only lists what is already
/// public — so the client remembers what it did. That is honest: it says "you
/// shared this", not "nobody else ever has". Publishing is idempotent, so a lost
/// note costs a repeat request, never a wrong state on the server.
class PublishedStore extends StateNotifier<Set<String>> {
  PublishedStore() : super(const <String>{}) {
    _restore();
  }

  static const _key = 'published_shortcodes';

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        state = {for (final value in decoded) value.toString()};
      }
    } catch (_) {
      // A corrupt note is not worth a crash; the Wall still works.
    }
  }

  bool isPublished(String shortcode) => state.contains(shortcode);

  Future<void> mark(String shortcode, {required bool published}) async {
    final next = {...state};
    if (published) {
      next.add(shortcode);
    } else {
      next.remove(shortcode);
    }
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(next.toList()));
    } catch (_) {
      // In-memory truth for this session is better than failing the action.
    }
  }
}
