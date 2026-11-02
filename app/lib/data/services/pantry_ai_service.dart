import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../models/pantry_item.dart';
import 'api_client.dart';

const _uuid = Uuid();

/// One line the model could read, matched back to the line it echoed.
class AiPantryLine {
  const AiPantryLine({
    required this.line,
    required this.name,
    this.quantity,
    this.unit,
  });

  /// The receipt's own words, echoed by the server so the client can line it up
  /// with the review sheet. Never trusted as a name on its own.
  final String line;
  final String name;
  final double? quantity;
  final PantryUnit? unit;

  static AiPantryLine? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final line = raw['line'];
    final name = raw['name'];
    if (line is! String || line.trim().isEmpty) return null;
    if (name is! String || name.trim().isEmpty) return null;

    final quantity = (raw['quantity'] as num?)?.toDouble();
    final unit = _unit(raw['unit']);
    return AiPantryLine(
      line: line,
      name: PantryParser.cleanName(name),
      quantity: quantity,
      // A unit with no amount would read as though you bought one.
      unit: quantity == null ? null : unit,
    );
  }

  /// Only the whitelist, never a synonym: an unknown unit is worse than none,
  /// and "cups" coerced to ml would be a lie about the amount.
  static PantryUnit? _unit(Object? raw) {
    if (raw is! String) return null;
    for (final unit in PantryUnit.values) {
      if (unit.label == raw) return unit;
    }
    return null;
  }
}

/// What one batched call to `/v1/pantry/parse` came back with.
class PantryAiResult {
  const PantryAiResult({
    required this.items,
    this.remaining,
    this.resetAt,
  });

  final List<AiPantryLine> items;
  final int? remaining;
  final DateTime? resetAt;

  static PantryAiResult parse(Map<String, dynamic> data) => PantryAiResult(
        items: [
          for (final raw in (data['items'] as List? ?? const []))
            if (AiPantryLine.fromJson(raw) case final item?) item,
        ],
        remaining: (data['remaining'] as num?)?.toInt(),
        resetAt: DateTime.tryParse('${data['reset_at'] ?? ''}'),
      );
}

/// Today's receipts are spent: not an error, a state with a date.
class PantryCapReached implements Exception {
  const PantryCapReached({this.resetAt});

  final DateTime? resetAt;

  @override
  String toString() => 'PantryCapReached($resetAt)';
}

/// The last resort for receipt lines the device could not read.
///
/// One call per receipt — never one per line, and never when the device read
/// everything itself. The image is not here and has no path to here: only the
/// leftover text, so OCR stays on the device.
class PantryAiService {
  PantryAiService({required ApiClient api, String Function()? newRequestId})
      : _api = api,
        _newRequestId = newRequestId;

  final ApiClient _api;

  /// Injected so a test can assert on the id it sent.
  final String Function()? _newRequestId;

  /// [lines] must already be the unreadable ones; the server takes 1–20.
  Future<PantryAiResult> read(List<String> lines) async {
    final clean = [
      for (final line in lines.take(maxLines))
        if (line.trim().isNotEmpty) line.trim(),
    ];
    if (clean.isEmpty) return const PantryAiResult(items: []);

    try {
      final response = await _api.post('/v1/pantry/parse', {
        'request_id': _newRequestId?.call() ?? _uuid.v4(),
        'lines': clean,
      });
      return PantryAiResult.parse(response);
    } on ApiError catch (error) {
      if (error.status == 429 || error.reason == 'daily_cap_reached') {
        throw const PantryCapReached();
      }
      rethrow;
    }
  }

  /// A receipt is at most one page; the contract caps a call at twenty lines.
  static const maxLines = 20;
}

/// Reads a receipt image with the server's vision model.
///
/// This replaced on-device OCR, which could not read a real till slip. The
/// image is uploaded, used for the call and not stored — the app says so before
/// the first upload. Typed and voice leftovers still go through
/// [PantryAiService], which never carries an image.
class PantryVisionService {
  PantryVisionService({required ApiClient api, String Function()? newRequestId})
      : _api = api,
        _newRequestId = newRequestId;

  final ApiClient _api;

  /// Injected so a test can assert on the id it sent.
  final String Function()? _newRequestId;

  Future<PantryAiResult> read(List<int> bytes, {String? mimeType}) async {
    if (bytes.isEmpty) return const PantryAiResult(items: []);
    try {
      final response = await _api.post('/v1/pantry/parse-image', {
        'request_id': _newRequestId?.call() ?? _uuid.v4(),
        'mime_type': mimeType ?? 'image/jpeg',
        'image_base64': base64Encode(bytes),
      });
      return PantryAiResult.parse(response);
    } on ApiError catch (error) {
      if (error.status == 429 || error.reason == 'daily_cap_reached') {
        throw const PantryCapReached();
      }
      rethrow;
    }
  }
}
