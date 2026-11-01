import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/api_client.dart';
import '../../data/services/assistant_service.dart';
import 'sync_providers.dart';

/// The ask door, as a provider so a test can answer without a network.
final assistantServiceProvider = Provider<AssistantService>(
  (ref) => AssistantService(api: ApiClient(auth: ref.watch(authServiceProvider))),
);
