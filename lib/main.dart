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

  // Firebase is optional — initializes only if google-services files exist
  await FirebaseService.initialize();

  // Set the correct app icon based on time of day (morning 6AM-6PM, evening 6PM-6AM)
  await setAppIconForCurrentTime();

  runApp(
    const ProviderScope(
      child: ReverApp(),
    ),
  );
}
