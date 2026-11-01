import 'dart:async';

import 'api_client.dart';

/// One exchange the client remembers, echoed back so a follow-up to a clarify
/// has context. The server keeps no thread.
class AssistantTurn {
  const AssistantTurn({required this.role, required this.text});

  /// `user` or `assistant`.
  final String role;
  final String text;

  Map<String, dynamic> toJson() => {'role': role, 'text': text};
}

/// One line of the diff card. `edits` is for showing, never for applying.
class AssistantEdit {
  const AssistantEdit({
    required this.op,
    required this.index,
    required this.text,
    this.previous,
  });

  /// `add`, `change` or `remove`.
  final String op;
  final int index;
  final String text;
  final String? previous;

  static AssistantEdit? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final op = raw['op'];
    if (op is! String) return null;
    return AssistantEdit(
      op: op,
      index: (raw['index'] as num?)?.toInt() ?? 0,
      text: (raw['text'] as String?) ?? '',
      previous: raw['previous'] as String?,
    );
  }
}

/// The full resulting arrays. Applying writes these verbatim — the client never
/// recomputes an edit, and never merges two of them.
class AssistantAppliable {
  const AssistantAppliable({
    required this.ingredients,
    required this.steps,
    required this.stepIngredients,
    required this.changes,
    required this.baseVersionId,
  });

  final List<String> ingredients;
  final List<String> steps;
  final List<List<int>> stepIngredients;
  final List<String> changes;
  final String baseVersionId;

  static AssistantAppliable? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final base = raw['base_version_id'];
    if (base is! String || base.isEmpty) return null;
    return AssistantAppliable(
      ingredients: [
        for (final line in (raw['ingredients'] as List? ?? const []))
          line.toString(),
      ],
      steps: [
        for (final step in (raw['steps'] as List? ?? const [])) step.toString(),
      ],
      stepIngredients: [
        for (final entry in (raw['step_ingredients'] as List? ?? const []))
          if (entry is List)
            [for (final i in entry) if (i is num) i.toInt()]
          else
            const <int>[],
      ],
      changes: [
        for (final change in (raw['changes'] as List? ?? const []))
          change.toString(),
      ],
      baseVersionId: base,
    );
  }
}

/// One reply from `/v1/assistant/ask`.
class AssistantReply {
  const AssistantReply({
    required this.intent,
    required this.answer,
    this.remaining,
    this.resetAt,
    this.edits = const [],
    this.appliable,
  });

  /// `answer`, `clarify` or `edit`.
  final String intent;
  final String answer;
  final int? remaining;
  final DateTime? resetAt;

  /// Present only for `edit`.
  final List<AssistantEdit> edits;
  final AssistantAppliable? appliable;

  bool get isEdit => intent == 'edit' && appliable != null;

  static AssistantReply parse(Map<String, dynamic> data) {
    return AssistantReply(
      intent: data['intent'] as String? ?? 'answer',
      answer: (data['answer'] as String?) ?? '',
      remaining: (data['remaining'] as num?)?.toInt(),
      resetAt: DateTime.tryParse('${data['reset_at'] ?? ''}'),
      edits: [
        for (final raw in (data['edits'] as List? ?? const []))
          if (AssistantEdit.fromJson(raw) case final edit?) edit,
      ],
      appliable: AssistantAppliable.fromJson(data['appliable']),
    );
  }
}

/// The daily questions are spent: not an error, a state with a date.
class AssistantCapReached implements Exception {
  const AssistantCapReached({this.resetAt});

  final DateTime? resetAt;

  @override
  String toString() => 'AssistantCapReached($resetAt)';
}

/// The ask door. One endpoint, three intents; nothing here writes journal data.
class AssistantService {
  AssistantService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<AssistantReply> ask({
    required String dishId,
    String? versionId,
    required String question,
    required String requestId,
    List<AssistantTurn> history = const [],
  }) async {
    try {
      final response = await _api.post('/v1/assistant/ask', {
        'dish_id': dishId,
        if (versionId != null) 'version_id': versionId,
        'question': question,
        'request_id': requestId,
        // The client's own last two exchanges, oldest first.
        if (history.isNotEmpty)
          'history': [for (final turn in history.take(4)) turn.toJson()],
      });
      return AssistantReply.parse(response);
    } on ApiError catch (error) {
      if (error.status == 429 || error.reason == 'daily_cap_reached') {
        throw const AssistantCapReached();
      }
      rethrow;
    }
  }
}
