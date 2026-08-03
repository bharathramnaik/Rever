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

  AppEnvironment.validate();

  await Supabase.initialize(
    url: AppEnvironment.supabaseUrl,
    publishableKey: AppEnvironment.supabasePublishableKey,
  );

  await FirebaseService.initialize();

  // Dev auto sign-in: only in debug builds AND when DEV_MODE is explicitly set.
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
  try {
    await Supabase.instance.client.auth.signInWithPassword(
      email: 'dev@rever.app',
      password: 'devpassword123',
    );
  } catch (_) {
    try {
      await Supabase.instance.client.auth.signUp(
        email: 'dev@rever.app',
        password: 'devpassword123',
      );
    } catch (_) {}
  }
}
