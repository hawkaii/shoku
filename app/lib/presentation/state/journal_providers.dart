import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/journal_data.dart';
import 'journal_store.dart';

final dishesProvider = Provider<List<Dish>>((ref) => ref.watch(journalStoreProvider));

final cooksProvider = Provider<List<CookLog>>((ref) => JournalData.allCooks);

final dishProvider = Provider.family<Dish, String>(
  (ref, id) => ref.watch(journalStoreProvider).firstWhere(
        (d) => d.id == id,
        orElse: () => ref.read(journalStoreProvider).first,
      ),
);

final totalCooksProvider = Provider<int>((ref) => JournalData.totalCooks);
final totalUpgradesProvider = Provider<int>((ref) => JournalData.totalUpgrades);
final signatureCountProvider = Provider<int>((ref) => JournalData.signatureCount);

/// Which version is being inspected in the dish dossier.
final inspectedVersionProvider = StateProvider.family<int, String>(
  (ref, dishId) => JournalData.dishFor(dishId).versions.length,
);

/// Library filter.
enum LibraryFilter { toCook, cooked }

final libraryFilterProvider =
    StateProvider<LibraryFilter>((ref) => LibraryFilter.toCook);

/// Cook-log sheet state (mock write path).
final pendingOutcomeProvider = StateProvider<CookOutcome?>((ref) => null);
final pendingChangesProvider = StateProvider<String>((ref) => '');
