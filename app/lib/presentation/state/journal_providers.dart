import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/journal_data.dart';
import 'journal_store.dart';

final dishesProvider =
    Provider<List<Dish>>((ref) => ref.watch(journalStoreProvider));

/// Every cook across every dish, newest first.
///
/// Derived from the database, not from the mock list — otherwise the timeline
/// keeps showing demo entries after the user has cooked something.
final cooksProvider = Provider<List<CookLog>>((ref) {
  final dishes = ref.watch(dishesProvider);
  final cooks = [
    for (final dish in dishes) ...dish.cooks,
  ]..sort((a, b) {
      final byTime = b.cookedAt.compareTo(a.cookedAt);
      return byTime != 0 ? byTime : b.id.compareTo(a.id);
    });
  return cooks;
});

/// Null when the dish isn't there (still loading, or tombstoned) — callers must
/// render that instead of indexing into the list.
final dishProvider = Provider.family<Dish?, String>(
  (ref, id) => ref.watch(dishesProvider).where((d) => d.id == id).firstOrNull,
);

final totalCooksProvider =
    Provider<int>((ref) => ref.watch(cooksProvider).length);

final totalUpgradesProvider = Provider<int>((ref) {
  final dishes = ref.watch(dishesProvider);
  return dishes.fold<int>(
    0,
    (sum, dish) =>
        sum + (dish.versions.length > 1 ? dish.versions.length - 1 : 0),
  );
});

final signatureCountProvider = Provider<int>((ref) {
  final dishes = ref.watch(dishesProvider);
  return dishes.where((d) => d.status == DishStatus.signature).length;
});

/// Which version is being inspected in the dish dossier. Defaults to the latest
/// version the dish actually has.
final inspectedVersionProvider =
    StateProvider.family<int, String>((ref, dishId) {
  final dish = ref.watch(dishProvider(dishId));
  return dish?.versions.length ?? 0;
});

/// Library filter.
enum LibraryFilter { toCook, cooked }

final libraryFilterProvider =
    StateProvider<LibraryFilter>((ref) => LibraryFilter.toCook);

/// Cook-log sheet state (mock write path).
final pendingOutcomeProvider = StateProvider<CookOutcome?>((ref) => null);
final pendingChangesProvider = StateProvider<String>((ref) => '');
