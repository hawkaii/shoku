import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/db/journal_repository.dart';
import '../../data/mock/journal_data.dart';

/// The journal is the product, so it is the one piece of real state: every
/// mutation goes through the repository and the UI re-reads what the database
/// now holds, so what you see is what was actually written.
class JournalStore extends StateNotifier<List<Dish>> {
  JournalStore(this._repo) : super(const []) {
    _boot();
  }

  final JournalRepository _repo;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> _boot() async {
    // First run: seed with the demo journal so the app doesn't open empty.
    if (await _repo.countDishes() == 0) {
      await _repo.seed(JournalData.dishes);
    }
    state = await _repo.loadDishes();
    _loaded = true;
  }

  Dish byId(String id) =>
      state.firstWhere((d) => d.id == id, orElse: () => state.first);

  Future<void> commitCook({
    required String dishId,
    required CookMood mood,
    required int rating,
    required String note,
    required List<String> changes,
    String? photoUrl,
  }) async {
    await _repo.commitCook(
      dishId: dishId,
      mood: mood,
      rating: rating,
      note: note,
      changes: changes,
      photoUrl: photoUrl,
    );
    state = await _repo.loadDishes();
  }

  Future<void> setStatus(String dishId, DishStatus status) async {
    await _repo.setStatus(dishId, status);
    state = await _repo.loadDishes();
  }

  Future<void> deleteDish(String dishId) async {
    await _repo.deleteDish(dishId);
    state = await _repo.loadDishes();
  }

  Future<void> refresh() async {
    state = await _repo.loadDishes();
  }
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => JournalRepository(ref.watch(databaseProvider)),
);

final journalStoreProvider = StateNotifierProvider<JournalStore, List<Dish>>(
  (ref) => JournalStore(ref.watch(journalRepositoryProvider)),
);
