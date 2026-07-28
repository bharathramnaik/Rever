import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/streak_model.dart';
import 'package:rever/src/data/repositories/streak_repository.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(ref.watch(supabaseProvider));
});

final streakProvider =
    FutureProvider.family<StreakModel?, String>((ref, profileId) {
  return ref.watch(streakRepositoryProvider).fetchByProfile(profileId);
});
