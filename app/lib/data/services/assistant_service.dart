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

/// One Wall card the kitchen thread may offer. The server chose it from
/// candidates it computed; the client never invents one.
class BotSuggestion {
  const BotSuggestion({
    required this.shortcode,
    required this.title,
    this.creator,
    this.thumbnailUrl = '',
    this.url,
    this.have = 0,
    this.total = 0,
    this.missing = const [],
  });

  final String shortcode;
  final String title;
  final String? creator;
  final String thumbnailUrl;
  final String? url;
  final int have;
  final int total;
  final List<String> missing;

  String get source => creator == null || creator!.isEmpty ? 'Wall' : 'Wall · @$creator';

  static BotSuggestion? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final shortcode = raw['shortcode'];
    if (shortcode is! String || shortcode.isEmpty) return null;
    return BotSuggestion(
      shortcode: shortcode,
      title: (raw['title'] as String?) ?? 'Untitled',
      creator: raw['creator'] as String?,
      thumbnailUrl: (raw['thumbnail_url'] as String?) ?? '',
      url: raw['url'] as String?,
      have: (raw['have'] as num?)?.toInt() ?? 0,
      total: (raw['total'] as num?)?.toInt() ?? 0,
      missing: [
        for (final line in (raw['missing'] as List? ?? const [])) line.toString(),
      ],
    );
  }
}

/// One fridge row the model read out of a sentence. Never written until the
/// cook confirms the card.
class BotCaptureItem {
  const BotCaptureItem({required this.name, this.quantity, this.unit});

  final String name;
  final double? quantity;
  final String? unit;

  static BotCaptureItem? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['name'];
    if (name is! String || name.trim().isEmpty) return null;
    return BotCaptureItem(
      name: name.trim(),
      quantity: (raw['quantity'] as num?)?.toDouble(),
      unit: raw['unit'] as String?,
    );
  }
}

/// A dish the thread could be about, offered when the request needed one.
class BotChoice {
  const BotChoice({required this.dishId, required this.title});

  final String dishId;
  final String title;

  static BotChoice? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['dish_id'];
    if (id is! String || id.isEmpty) return null;
    return BotChoice(dishId: id, title: (raw['title'] as String?) ?? 'Dish');
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
    this.suggestions = const [],
    this.items = const [],
    this.choices = const [],
  });

  /// `answer`, `clarify` or `edit`.
  final String intent;
  final String answer;
  final int? remaining;
  final DateTime? resetAt;

  /// Present only for `edit`.
  final List<AssistantEdit> edits;
  final AssistantAppliable? appliable;

  /// `suggest`: at most three cards the server's matcher chose.
  final List<BotSuggestion> suggestions;

  /// `capture`: fridge rows read out of a sentence, for a confirmation card.
  final List<BotCaptureItem> items;

  /// `clarify`: dishes that would answer "which one?".
  final List<BotChoice> choices;

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
      suggestions: [
        for (final raw in (data['suggestions'] as List? ?? const []))
          if (BotSuggestion.fromJson(raw) case final s?) s,
      ],
      items: [
        for (final raw in (data['items'] as List? ?? const []))
          if (BotCaptureItem.fromJson(raw) case final i?) i,
      ],
      choices: [
        for (final raw in (data['choices'] as List? ?? const []))
          if (BotChoice.fromJson(raw) case final c?) c,
      ],
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
    required String scope,
    String? dishId,
    String? versionId,
    int? stepIndex,
    required String question,
    required String requestId,
    List<AssistantTurn> history = const [],
    List<String> exclude = const [],
  }) async {
    try {
      final response = await _api.post('/v1/assistant/ask', {
        'scope': scope,
        if (dishId != null) 'dish_id': dishId,
        if (versionId != null) 'version_id': versionId,
        if (stepIndex != null) 'step_index': stepIndex,
        'question': question,
        'request_id': requestId,
        // The client's own last two exchanges, oldest first.
        if (history.isNotEmpty)
          'history': [for (final turn in history.take(4)) turn.toJson()],
        // "Not this" reshuffles without repeating the same three cards.
        if (exclude.isNotEmpty) 'exclude': exclude,
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
