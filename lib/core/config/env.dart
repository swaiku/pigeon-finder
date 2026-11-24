/// Supabase configuration, provided at build/run time via --dart-define.
/// Never hardcode keys here.
class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Base URL of pigeon-api, where the app gets the piaf models, such as
  /// `https://host/api`. Empty: the app only uses the bundled models.
  static const piafApiUrl = String.fromEnvironment('PIAF_API_URL');
}
