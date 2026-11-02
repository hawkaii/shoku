import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/assistant_turn_repository.dart';
import '../../data/services/api_client.dart';
import '../../data/services/assistant_service.dart';
import 'journal_store.dart';
import 'sync_providers.dart';

/// The ask door, as a provider so a test can answer without a network.
final assistantServiceProvider = Provider<AssistantService>(
  (ref) => AssistantService(api: ApiClient(auth: ref.watch(authServiceProvider))),
);

/// The chat's local memory. One repository, the app's one database.
final assistantTurnRepositoryProvider = Provider<AssistantTurnRepository>(
  (ref) => AssistantTurnRepository(ref.watch(databaseProvider)),
);
