import 'package:flutter/foundation.dart';

class AppEnvironment {
  AppEnvironment._();

  /// Supabase project URL. Must be provided via `--dart-define=SUPABASE_URL=...`.
  /// Never commit real credentials as defaults — they are extractable from binaries.
  static String get supabaseUrl => const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: '',
      );

  /// Supabase anon/publishable key. Must be provided via `--dart-define`.
  static String get supabasePublishableKey => const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      );

  /// Google OAuth web client ID. Must be provided via `--dart-define`.
  static String get googleWebClientId => const String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue: '',
      );

  /// Dev mode bypasses auth and uses demo profiles.
  /// Defaults to FALSE — release builds must explicitly opt in with
  /// `--dart-define=DEV_MODE=true` (only for local development).
  static bool get isDev => const bool.fromEnvironment(
        'DEV_MODE',
        defaultValue: false,
      );

  /// Base URL for the Rever AI (FastAPI) service.
  /// Defaults to the local dev server; override for production with:
  ///   flutter run --dart-define=AI_BASE_URL=https://ai.rever.app
  static String get aiBaseUrl => const String.fromEnvironment(
        'AI_BASE_URL',
        defaultValue: 'http://localhost:8000',
      );

  /// Validates that required config is present. Call early in `main()`.
  static void validate() {
    assert(() {
      // In debug builds, allow empty config (dev mode uses demo data).
      return true;
    }());
    if (!isDev) {
      if (supabaseUrl.isEmpty) {
        throw StateError(
          'SUPABASE_URL is not set. Provide it via --dart-define.',
        );
      }
      if (supabasePublishableKey.isEmpty) {
        throw StateError(
          'SUPABASE_ANON_KEY is not set. Provide it via --dart-define.',
        );
      }
    }
  }
}

