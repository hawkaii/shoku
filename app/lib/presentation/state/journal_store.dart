import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/db/journal_repository.dart';
import '../../data/mock/journal_data.dart';

/// The journal is the product, so it is the one piece of real state: every
/// mutation goes through the repository and the UI re-reads what the database
/// now holds, so what you see is what was actually written.
enum JournalStatus { loading, ready, failed }

class JournalStore extends StateNotifier<List<Dish>> {
  JournalStore(this._repo, {void Function(JournalStatus)? onStatus})
      : _onStatus = onStatus,
        super(const []) {
    _boot();
  }

  final JournalRepository _repo;
  final void Function(JournalStatus)? _onStatus;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Object? _error;
  Object? get error => _error;

  Future<void> _boot() async {
    try {
      // Seed once, tracked by a database flag rather than by "are there rows" —
      // a user who deletes everything must not get the demo kitchen back.
      if (!await _repo.isSeeded()) {
        await _repo.seed(JournalData.dishes);
      }
      state = await _repo.loadDishes();
      _loaded = true;
      _onStatus?.call(JournalStatus.ready);
    } catch (error) {
      // Never leave the UI on a spinner with no explanation, and never let a
      // boot failure escape as an unhandled async error.
      _error = error;
      state = const [];
      _loaded = true;
      _onStatus?.call(JournalStatus.failed);
    }
  }

  Future<void> retry() async {
    _error = null;
    state = const [];
    await _boot();
  }

  Dish byId(String id) =>
      state.firstWhere((d) => d.id == id, orElse: () => state.first);

  Future<int?> commitCook({
    required String dishId,
    required CookMood mood,
    required int rating,
    required String note,
    required List<String> changes,
    String? photoUrl,
  }) async {
    final version = await _repo.commitCook(
      dishId: dishId,
      mood: mood,
      rating: rating,
      note: note,
      changes: changes,
      photoUrl: photoUrl,
    );
    state = await _repo.loadDishes();
    return version;
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

/// Whether the journal has finished loading — the UI needs this to tell
/// "still opening" apart from "nothing here yet".
final journalStatusProvider = StateProvider<JournalStatus>(
  (ref) => JournalStatus.loading,
);

final journalStoreProvider = StateNotifierProvider<JournalStore, List<Dish>>(
  (ref) => JournalStore(
    ref.watch(journalRepositoryProvider),
    onStatus: (status) =>
        ref.read(journalStatusProvider.notifier).state = status,
  ),
);
