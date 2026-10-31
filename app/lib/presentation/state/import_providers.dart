import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/api_client.dart';
import '../../data/services/import_service.dart';
import '../../data/services/pending_import.dart';
import 'journal_store.dart';
import 'sync_providers.dart';

/// The import service the sheet talks to.
///
/// Exposed as a provider so a test can drive the real sheet against a fake
/// server, and so the client is built once with the session's token.
final importServiceProvider = Provider<ImportService>(
  (ref) => ImportService(
    api: ApiClient(auth: ref.watch(authServiceProvider)),
    repository: ref.watch(journalRepositoryProvider),
  ),
);

/// Where an in-flight import is remembered between openings — and between
/// launches, because a killed app must not lose one either.
final pendingImportStoreProvider = Provider<PendingImportStore>(
  (ref) => PendingImportStore(),
);
