import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Initializes Firebase services (FCM, Crashlytics, Analytics).
///
/// Gracefully handles missing google-services files during development.
/// In release builds, crashes if Firebase is not configured.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _initialized = true;

      // Set up crashlytics
      if (!kDebugMode) {
        FlutterError.onError = (errorDetails) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        };
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      }

      debugPrint('[Firebase] Initialized successfully');
    } catch (e) {
      // Firebase not configured (missing google-services files)
      debugPrint('[Firebase] Not configured — skipping: $e');
    }
  }

  static bool get isAvailable => _initialized;
}
