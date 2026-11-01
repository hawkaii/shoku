/// Where the app talks to.
///
/// The publishable key is designed to sit in a client binary — it can only do
/// what row-level security allows, and our tables have RLS on with no policies.
/// The secret key never ships, and the app never talks to Postgres directly:
/// every read and write goes through our own API.
class ShokuConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qfoqmdnpxbddjobwtbqu.supabase.co',
  );

  static const supabaseKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_U46uk6Qmx77uRUIY-EkfKg_LLteWAzV',
  );

  /// Our API. This is the dev VM's public address, which is plain HTTP — fine
  /// for testing, and the reason release builds need HTTPS before shipping
  /// (Android blocks cleartext outside debug).
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://35.188.27.251:8000',
  );

  static const authRedirect = 'com.shoku.app://login-callback';
}
