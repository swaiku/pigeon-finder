/// Supabase configuration, provided at build/run time via --dart-define.
/// Never hardcode keys here.
class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
