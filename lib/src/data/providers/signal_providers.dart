import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/repositories/signal_repository.dart';

final signalRepositoryProvider = Provider<SignalRepository>((ref) {
  return SignalRepository(ref.watch(supabaseProvider));
});

/// Dev mode bypasses Supabase entirely, so signal recording is a no-op there.
final signalRecorderProvider = Provider<SignalRecorder>((ref) {
  return SignalRecorder(
    sink: ref.watch(signalRepositoryProvider),
    enabled: !AppEnvironment.isDev,
    profileIdOf: () => ref.read(activeProfileIdProvider),
  );
});
