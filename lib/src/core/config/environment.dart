/// Application configuration loaded from environment variables.
///
/// In development, values can be set via --dart-define flags:
///   flutter run --dart-define=SUPABASE_URL=https://x.supabase.co
///
/// In production, values should be compiled in via --dart-define in CI/CD.
class AppEnvironment {
  AppEnvironment._();

  static String get supabaseUrl => const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://your-project.supabase.co',
      );

  static String get supabaseAnonKey => const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'your-anon-key',
      );

  static String get googleWebClientId => const String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue: '693565124656-vuev5mjnbqu6jqvfq3rnc4g37dttu24g.apps.googleusercontent.com',
      );
}
