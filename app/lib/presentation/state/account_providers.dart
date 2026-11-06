import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/account_service.dart';
import '../../data/services/api_client.dart';
import 'auth_providers.dart';

/// Account deletion is one call and one wipe; it needs no store of its own.
final accountServiceProvider = Provider<AccountService>(
  (ref) => AccountService(api: ApiClient(auth: ref.watch(authServiceProvider))),
);
