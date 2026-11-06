import 'api_client.dart';

/// The one destructive call in the app.
///
/// Deliberately not a sync operation: the server erases the rows, and the
/// device erases its copy straight after, so "deleted" means deleted rather
/// than hidden.
class AccountService {
  AccountService({required ApiClient api}) : _api = api;

  final ApiClient _api;

  Future<void> deleteAccount() => _api.delete('/v1/account');
}
