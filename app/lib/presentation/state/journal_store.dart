import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/failure_log.dart';
import 'auth_providers.dart';

import '../../data/db/app_database.dart';
import '../../data/db/journal_repository.dart';
import '../../data/mock/journal_data.dart';
import '../../data/mock/sample_recipe.dart';

/// The journal is the product, so it is the one piece of real state: every
/// mutation goes through the repository and the UI re-reads what the database
/// now holds, so what you see is what was actually written.
enum JournalStatus { loading, ready, failed }

class JournalStore extends StateNotifier<List<Dish>> {
  JournalStore(
    this._repo, {
    void Function(JournalStatus)? onStatus,
    Future<void> Function()? onChanged,
    bool Function()? isSignedIn,
    Dish? sample,
  })  : _onStatus = onStatus,
        _onChanged = onChanged,
        _isSignedIn = isSignedIn,
        _sample = sample,
        super(const []) {
    _boot();
  }

  final JournalRepository _repo;
  final void Function(JournalStatus)? _onStatus;

  /// Fired after every local mutation: the sync layer hooks in here without the
  /// store knowing anything about HTTP.
  final Future<void> Function()? _onChanged;

  /// Asked at boot, not at the shell's first frame: the sample has to be in the
  /// same read that fills the Journal, or the cook sees an empty kitchen and a
  /// reload repeats it.
  final bool Function()? _isSignedIn;

  /// The starter dish, or null when this build does not want one (a test that
  /// models its own kitchen, for instance).
  final Dish? _sample;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Object? _error;
  Object? get error => _error;

  Future<void> _boot() async {
    try {
      // The app ships empty. An install that already carries the demo kitchen
      // loses it once, and nothing the user imported is touched.
      await _repo.removeDemoKitchen(JournalData.demoDishIds);
      await _ensureSampleBeforeFirstRead();
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

  /// Seeding belongs to the load, not after it. Signed out, with the sample
  /// not yet taken away, a kitchen that has never had it gets it in the very
  /// first `loadDishes()` — which is also what a reload reads.
  Future<void> _ensureSampleBeforeFirstRead() async {
    try {
      if (_isSignedIn?.call() == true) return;
      final sample = _sample;
      if (sample == null) return;
      if (await _repo.sampleWasRemoved() ||
          await _repo.sampleWasSeeded() ||
          await _repo.hasSample(sample.id)) {
        return;
      }
      // Only an empty kitchen gets the starter dish. A journal with anything in
      // it belongs to its cook, and a second dish would be an imposition.
      if (await _repo.countDishes() > 0) return;
      await _repo.seedSample(sample);
    } catch (error, stack) {
      // A sample is a kindness, not a dependency — but a sample that did not
      // arrive is still worth a line.
      logFailure('sample recipe seed', error, stack);
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
    String? photoKey,
  }) async {
    final version = await _repo.commitCook(
      dishId: dishId,
      mood: mood,
      rating: rating,
      note: note,
      changes: changes,
      photoUrl: photoUrl,
      photoKey: photoKey,
    );
    state = await _repo.loadDishes();
    unawaited(_onChanged?.call() ?? Future<void>.value());
    return version;
  }

  /// Applies an assistant edit. Returns the new version number, or null when
  /// the local head moved and the edit must be recomputed.
  Future<int?> applyEditVersion({
    required String dishId,
    required String baseVersionId,
    required List<String> ingredients,
    required List<String> steps,
    required List<List<int>> stepIngredients,
    required List<String> changes,
  }) async {
    final number = await _repo.applyEditVersion(
      dishId: dishId,
      baseVersionId: baseVersionId,
      ingredients: ingredients,
      steps: steps,
      stepIngredients: stepIngredients,
      changes: changes,
    );
    state = await _repo.loadDishes();
    if (number != null) unawaited(_onChanged?.call() ?? Future<void>.value());
    return number;
  }

  Future<void> setStatus(String dishId, DishStatus status) async {
    await _repo.setStatus(dishId, status);
    state = await _repo.loadDishes();
    unawaited(_onChanged?.call() ?? Future<void>.value());
  }

  Future<void> deleteDish(String dishId) async {
    await _repo.deleteDish(dishId);
    state = await _repo.loadDishes();
    unawaited(_onChanged?.call() ?? Future<void>.value());
  }

  Future<void> refresh() async {
    state = await _repo.loadDishes();
  }

  /// A local re-read, for the shell: if the store finished booting before the
  /// Journal mounted, the page still starts from the rows the database holds.
  /// Never triggers a sync — this is not a change, it is a catch-up.
  Future<void> reload() async {
    try {
      state = await _repo.loadDishes();
    } catch (error, stack) {
      // The Journal already has a state it can render; the line says why this
      // re-read changed nothing.
      logFailure('journal reload', error, stack);
    }
  }

  /// The sample recipe exists for exactly one audience: a kitchen with no
  /// account. Signed in, it is removed for good.
  Future<void> ensureSample({
    required bool signedIn,
    required Dish sample,
  }) async {
    // A sample is a kindness, not a dependency: if the write fails, the shell
    // must still open. Nothing about the sample may take the journal down.
    try {
      if (signedIn) {
        await dropSample(sampleId: sample.id);
        return;
      }
      if (await _repo.sampleWasRemoved() || await _repo.hasSample(sample.id)) {
        return;
      }
      await _repo.seedSample(sample);
      state = await _repo.loadDishes();
    } catch (error, stack) {
      // Leave the journal as it was; the empty state is a valid screen, and the
      // failure is now on the record.
      logFailure('journal sample ensure', error, stack);
    }
  }

  /// Signing in takes the sample away before the first push, so its rows can
  /// never reach the server.
  Future<void> dropSample({required String sampleId}) async {
    try {
      if (await _repo.hasSample(sampleId)) {
        await _repo.removeSample(sampleId);
        state = await _repo.loadDishes();
      }
    } catch (error, stack) {
      // Signing in must not fail because a local delete did.
      logFailure('journal sample drop', error, stack);
    }
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

/// The starter dish for a signed-out kitchen. Null opts out — a test that
/// brings its own journal does not need a stranger's paneer in it.
final sampleRecipeProvider = Provider<Dish?>((ref) => SampleRecipe.dish());

final journalStoreProvider = StateNotifierProvider<JournalStore, List<Dish>>(
  (ref) => JournalStore(
    ref.watch(journalRepositoryProvider),
    // Late-bound like the sync hook: reading auth at boot is enough, and a
    // sign-in is handled by the sync controller dropping the sample.
    isSignedIn: () => ref.read(authServiceProvider).isSignedIn,
    sample: ref.watch(sampleRecipeProvider),
    onStatus: (status) =>
        ref.read(journalStatusProvider.notifier).state = status,
    // Late-bound: sync_providers imports this file, so the callback is resolved
    // at call time rather than creating an import cycle.
    onChanged: () async {
      final controller = ref.read(syncHookProvider);
      if (controller != null) await controller();
    },
  ),
);

/// Bound at the app root (see main.dart) so the store can trigger a sync after
/// a mutation without importing the sync layer and creating a dependency cycle.
typedef SyncCallback = Future<void> Function();
final syncHookProvider = Provider<SyncCallback?>((ref) => null);
