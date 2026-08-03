import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app/app.dart';
import 'src/core/config/environment.dart';
import 'src/core/providers/app_icon_provider.dart';
import 'src/core/services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppEnvironment.supabaseUrl,
    publishableKey: AppEnvironment.supabasePublishableKey,
  );

  await FirebaseService.initialize();

  // Only auto-sign-in the dev demo account in debug builds. In release the
  // real auth flow (email/Google sign-in) must be used.
  if (kDebugMode && AppEnvironment.isDev) {
    await _autoSignIn();
  }

  await setAppIconForCurrentTime();

  runApp(
    const ProviderScope(
      child: ReverApp(),
    ),
  );
}

Future<void> _autoSignIn() async {
  final client = Supabase.instance.client;
  if (client.auth.currentSession != null) return;
  try {
    await client.auth.signInWithPassword(
      email: 'dev@rever.app',
      password: 'devpassword123',
    );
  } on AuthException catch (e, st) {
    debugPrint('[dev][auth] signIn failed: $e\n$st');
    try {
      await client.auth.signUp(
        email: 'dev@rever.app',
        password: 'devpassword123',
      );
    } on AuthException catch (e, st) {
      debugPrint('[dev][auth] signUp also failed: $e\n$st');
    }
  } catch (e, st) {
    debugPrint('[dev][auth] unexpected error: $e\n$st');
  }
}

