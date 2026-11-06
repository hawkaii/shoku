import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/failure_log.dart';
import '../../data/db/pantry_repository.dart';
import '../../data/models/pantry_item.dart';
import '../../data/services/api_client.dart';
import '../../data/services/pantry_ai_service.dart';
import '../../data/services/receipt_image.dart';
import '../../data/services/suggestions_service.dart';
import 'journal_store.dart';
import 'sync_providers.dart';

/// The pantry in memory, loaded from disk and refreshed after every write.
class PantryStore extends StateNotifier<List<PantryItem>> {
  PantryStore(this._repo, this._ref) : super(const []) {
    _load();
    // A pull can land rows this store never saw, so a sync that settles is a
    // reason to re-read the shelf. Without this, the fridge only ever shows
    // what this device typed until the app is reopened.
    _ref.listen<SyncStatus>(syncStatusProvider, (previous, next) {
      if (next == SyncStatus.idle && previous != SyncStatus.idle) {
        unawaited(reload());
      }
    });
  }

  final PantryRepository _repo;
  final Ref _ref;
  bool _ready = false;
  bool get isReady => _ready;

  /// What this kitchen already calls its ingredients. Receipt lines are read
  /// against it so a brand falls off a product it has met before.
  Set<String> get vocabulary =>
      PantryParser.vocabularyOf(state.map((item) => item.name));

  Future<void> _load() async {
    try {
      state = await _repo.load();
    } catch (error, stack) {
      // An unreadable shelf renders as an empty one; the line says it was not
      // empty, it just could not be read.
      logFailure('pantry load', error, stack);
      state = const [];
    } finally {
      _ready = true;
    }
  }

  /// Re-reads the shelf without calling back into sync. Used when a sync pass
  /// settles: the pull is the thing that changed, not this device.
  Future<void> reload() async {
    try {
      state = await _repo.load();
    } catch (error, stack) {
      logFailure('pantry reload', error, stack);
      return;
    }
    _ref.read(pantryRevisionProvider.notifier).state++;
  }

  Future<void> refresh() async {
    await reload();
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

  /// Deletes a selection. One refresh and one sync for the batch, because
  /// clearing six rows is one action to the cook.
  Future<void> removeMany(Iterable<String> ids) async {
    for (final id in ids) {
      await _repo.remove(id);
    }
    await refresh();
  }

  /// Adds a confirmed line. A line this shelf has already confirmed keeps its
  /// name and amount: the receipt's raw text is remembered as an alias, so next
  /// week's "AMUL BUTTER 500G" meets the same butter instead of a duplicate.
  Future<PantryItem> confirmLine(
    ParsedPantryLine line, {
    String source = 'typed',
  }) async {
    final rawKey = PantryParser.key(line.raw);
    PantryItem? known;
    for (final item in state) {
      if (item.aliases.any((alias) => PantryParser.key(alias) == rawKey)) {
        known = item;
        break;
      }
    }
    if (known == null) {
      final nameKey = PantryParser.key(line.name);
      for (final item in state) {
        if (PantryParser.key(item.name) == nameKey) {
          known = item;
          break;
        }
      }
    }
    if (known != null) {
      final merged = known.copyWith(
        quantity: line.quantity,
        clearQuantity: line.quantity == null,
        unit: line.unit,
        clearUnit: line.unit == null,
        aliases: {...known.aliases, line.raw}.toList(),
        wanted: false,
      );
      await save(merged);
      return merged;
    }
    final item = await _repo.add(
      name: line.name,
      quantity: line.quantity,
      unit: line.unit,
      aliases: [line.raw],
      source: source,
    );
    await refresh();
    return item;
  }

  /// Adds a missing recipe line to "To buy", untouched and unmeasured.
  Future<void> want(String name) async {
    final key = PantryParser.key(name);
    if (state.any((item) => PantryParser.key(item.name) == key)) return;
    await add(name: name, wanted: true, source: 'manual');
  }

  /// Adds a batch of missing lines and returns the ids it created, so the
  /// caller can offer Undo. One refresh, one sync for the whole list.
  Future<List<String>> wantMany(Iterable<String> names) async {
    final seen = {for (final item in state) PantryParser.key(item.name)};
    final ids = <String>[];
    for (final name in names) {
      final key = PantryParser.key(name);
      if (key.isEmpty || !seen.add(key)) continue;
      final item =
          await _repo.add(name: name, wanted: true, source: 'suggestion');
      ids.add(item.id);
    }
    if (ids.isNotEmpty) await refresh();
    return ids;
  }

  /// Takes matched amounts out of stock. Returns how many lines could not be
  /// deducted because their units do not compare.
  Future<int> deduct(
      List<({PantryItem item, double amount, PantryUnit unit})> lines) async {
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

final pantryAiServiceProvider = Provider<PantryAiService>(
  (ref) => PantryAiService(
    api: ApiClient(auth: ref.watch(authServiceProvider)),
  ),
);

final pantryVisionServiceProvider = Provider<PantryVisionService>(
  (ref) => PantryVisionService(
    api: ApiClient(auth: ref.watch(authServiceProvider)),
  ),
);

/// Picking bytes, behind a seam a widget test can answer without a camera.
typedef ReceiptImagePicker = Future<List<int>?> Function(ImageSource source);

final receiptImagePickerProvider = Provider<ReceiptImagePicker>(
  (ref) => ReceiptImage.pickFrom,
);

final suggestionsServiceProvider = Provider<SuggestionsService>(
  (ref) => SuggestionsService(
    api: ApiClient(auth: ref.watch(authServiceProvider)),
  ),
);

final suggestionsProvider = FutureProvider<List<FeedSuggestion>>((ref) {
  ref.watch(pantryRevisionProvider);
  // A shelf asked for before the session was restored may have gone out with
  // no bearer token and stayed empty for the life of the page. The auth stream
  // is the wake-up: sign-in (or a refreshed token) is a reason to ask again.
  ref.watch(authEventProvider);
  return ref.watch(suggestionsServiceProvider).fetch();
});

final pantryRepositoryProvider = Provider<PantryRepository>(
  (ref) => PantryRepository(ref.watch(databaseProvider)),
);

final pantryStoreProvider =
    StateNotifierProvider<PantryStore, List<PantryItem>>(
  (ref) => PantryStore(ref.watch(pantryRepositoryProvider), ref),
);
