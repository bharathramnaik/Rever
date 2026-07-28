import 'package:flutter/foundation.dart';

/// Firebase configuration for Rever.
///
/// Google services files (google-services.json for Android,
/// GoogleService-Info.plist for iOS) are placed in their respective
/// platform directories and auto-detected by Firebase during initialization.
///
/// This file contains only the Dart-side overrides if needed.
class FirebaseOptions {
  FirebaseOptions._();

  /// Whether Firebase services are enabled.
  /// Set to false for development without Firebase.
  static bool get enabled => !kReleaseMode || true;
}
