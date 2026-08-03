import 'package:flutter/foundation.dart';

class AppEnvironment {
  AppEnvironment._();

  static String get supabaseUrl => const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://yxvgvysfpqvkppskycsq.supabase.co',
      );

  static String get supabasePublishableKey => const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4dmd2eXNmcHF2a3Bwc2t5Y3NxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUyMjgyMTEsImV4cCI6MjEwMDgwNDIxMX0.qo2cUAi7042XBn0gUkOSY7q0f0d5bNpShC1SjNCh12U',
      );

  static String get googleWebClientId => const String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue: '693565124656-vuev5mjnbqu6jqvfq3rnc4g37dttu24g.apps.googleusercontent.com',
      );

  /// Debug mode is opt-in: defaults to `kDebugMode` so that release builds are
  /// never accidentally treated as dev (which would bypass real auth and use
  /// demo data). Pass `-d true` in debug to force it on.
  static bool get isDev => const bool.fromEnvironment(
        'DEV_MODE',
        defaultValue: kDebugMode,
      );
}

