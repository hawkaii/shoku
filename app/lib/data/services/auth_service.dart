import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/shoku_config.dart';

/// Thin wrapper over Supabase Auth.
///
/// The app only needs three things from it: a session, the access token that
/// proves it, and a way to sign out. Everything else — the journal, imports,
/// photos — goes through our own API, so this class never touches tables.
class AuthService {
  AuthService({SupabaseClient? client}) : _client = client;

  static bool _initialised = false;
  SupabaseClient? _client;

  SupabaseClient get _supabase {
    final injected = _client;
    if (injected != null) return injected;
    return Supabase.instance.client;
  }

  /// Called once at start-up. Safe to call twice.
  static Future<void> init() async {
    if (_initialised) return;
    await Supabase.initialize(
      url: ShokuConfig.supabaseUrl,
      anonKey: ShokuConfig.supabaseKey,
    );
    _initialised = true;
  }

  Session? get session =>
      _initialised || _client != null ? _supabase.auth.currentSession : null;

  bool get isSignedIn => session != null;

  /// The token the API expects in `Authorization: Bearer`.
  String? get accessToken => session?.accessToken;

  /// Supabase user id — the `sub` claim the server uses as the owner.
  String? get userId => session?.user.id;

  Stream<AuthState> get changes => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signInWithPassword(String email, String password) =>
      _supabase.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUp(String email, String password) =>
      _supabase.auth.signUp(email: email, password: password);

  /// Google is wired here but only works once the provider is enabled in the
  /// Supabase project. Until then the button stays hidden rather than failing
  /// in the user's face.
  Future<bool> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: ShokuConfig.authRedirect,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() => _supabase.auth.signOut();
}
