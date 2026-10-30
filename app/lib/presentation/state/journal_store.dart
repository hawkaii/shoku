import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/journal_data.dart';

/// The journal is the product, so it is the one piece of real state:
/// committing a cook appends a version and a log entry.
class JournalStore extends StateNotifier<List<Dish>> {
  JournalStore() : super(JournalData.dishes);

  Dish byId(String id) => state.firstWhere((d) => d.id == id, orElse: () => state.first);

  void commitCook({
    required String dishId,
    required CookMood mood,
    required int rating,
    required String note,
    required List<String> changes,
    String? photoUrl,
  }) {
    final dish = byId(dishId);
    final nextNumber = dish.versions.length + 1;
    final previous = dish.versions.last;

    final version = RecipeVersion(
      number: nextNumber,
      changes: changes.isEmpty ? const ['No changes'] : changes,
      ingredients: previous.ingredients,
      createdAt: DateTime.now(),
      steps: previous.steps,
      // A real macro pass lands with the nutrition backend; until then the
      // estimate moves with the number of changes so the diff has something
      // honest to say.
      kcal: dish.baselineKcal + (changes.length * 18),
      protein: dish.baselineProtein + (changes.length * 2),
    );

    final log = CookLog(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      cookedAt: DateTime.now(),
      versionNumber: nextNumber,
      photoUrl: photoUrl ?? dish.coverUrl,
      outcome: rating >= 5
          ? CookOutcome.nailedIt
          : rating >= 3
              ? CookOutcome.good
              : CookOutcome.needsWork,
      note: note,
      changes: changes,
      mood: mood,
      rating: rating,
    );

    state = [
      for (final d in state)
        if (d.id == dishId)
          d.copyWith(
            versions: [...d.versions, version],
            cooks: [log, ...d.cooks],
            coverUrl: photoUrl ?? d.coverUrl,
            status: d.cooks.length + 1 >= 3 ? DishStatus.signature : DishStatus.cooked,
          )
        else
          d,
    ];
  }
}

extension DishStatusActions on JournalStore {
  void setStatus(String dishId, DishStatus status) {
    state = [
      for (final d in state)
        if (d.id == dishId) d.copyWith(status: status) else d,
    ];
  }
}

final journalStoreProvider =
    StateNotifierProvider<JournalStore, List<Dish>>((ref) => JournalStore());
