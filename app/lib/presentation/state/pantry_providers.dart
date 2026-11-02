import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/pantry_repository.dart';
import '../../data/models/pantry_item.dart';
import '../../data/services/api_client.dart';
import '../../data/services/suggestions_service.dart';
import 'journal_store.dart';
import 'sync_providers.dart';

/// The pantry in memory, loaded from disk and refreshed after every write.
class PantryStore extends StateNotifier<List<PantryItem>> {
  PantryStore(this._repo, this._ref) : super(const []) {
    _load();
  }

  final PantryRepository _repo;
  final Ref _ref;
  bool _ready = false;
  bool get isReady => _ready;

  Future<void> _load() async {
    try {
      state = await _repo.load();
    } catch (_) {
      state = const [];
    } finally {
      _ready = true;
    }
  }

  Future<void> refresh() async {
    state = await _repo.load();
    _ref.read(pantryRevisionProvider.notifier).state++;
    // A pantry write is a local change like any other: it has to reach the
    // server, or the shelf only exists on the device that typed it.
    unawaited(_ref.read(syncHookProvider)?.call() ?? Future<void>.value());
  }

  Future<void> add({
    required String name,
    double? quantity,
    PantryUnit? unit,
    List<String> aliases = const [],
    bool wanted = false,
    String source = 'manual',
  }) async {
    await _repo.add(
      name: name,
      quantity: quantity,
      unit: unit,
      aliases: aliases,
      wanted: wanted,
      source: source,
    );
    await refresh();
  }

  Future<void> save(PantryItem item) async {
    await _repo.save(item);
    await refresh();
  }

  Future<void> remove(String id) async {
    await _repo.remove(id);
    await refresh();
  }

  /// Adds a missing recipe line to "To buy", untouched and unmeasured.
  Future<void> want(String name) async {
    final key = PantryParser.key(name);
    if (state.any((item) => PantryParser.key(item.name) == key)) return;
    await add(name: name, wanted: true, source: 'manual');
  }

  /// Takes matched amounts out of stock. Returns how many lines could not be
  /// deducted because their units do not compare.
  Future<int> deduct(List<({PantryItem item, double amount, PantryUnit unit})> lines) async {
    var skipped = 0;
    for (final line in lines) {
      final left = line.item.quantity == null || line.item.unit == null
          ? null
          : PantryParser.deductAmount(
              have: line.item.quantity!,
              haveUnit: line.item.unit!,
              needed: line.amount,
              neededUnit: line.unit,
            );
      if (left == null) {
        skipped++;
        continue;
      }
      await _repo.save(line.item.copyWith(quantity: left));
    }
    await refresh();
    return skipped;
  }
}

/// Bumped after every write so the shelf re-scores against the new shelf.
final pantryRevisionProvider = StateProvider<int>((ref) => 0);

final suggestionsServiceProvider = Provider<SuggestionsService>(
  (ref) => SuggestionsService(
    api: ApiClient(auth: ref.watch(authServiceProvider)),
  ),
);

final suggestionsProvider = FutureProvider<List<FeedSuggestion>>((ref) {
  ref.watch(pantryRevisionProvider);
  return ref.watch(suggestionsServiceProvider).fetch();
});

final pantryRepositoryProvider = Provider<PantryRepository>(
  (ref) => PantryRepository(ref.watch(databaseProvider)),
);

final pantryStoreProvider =
    StateNotifierProvider<PantryStore, List<PantryItem>>(
  (ref) => PantryStore(ref.watch(pantryRepositoryProvider), ref),
);
