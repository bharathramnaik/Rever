import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
// WidgetRef is exported by flutter_riverpod.
import 'package:rever/src/data/models/streak_model.dart';
import 'package:rever/src/data/repositories/streak_repository.dart';

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(ref.watch(supabaseProvider));
});

final streakProvider =
    FutureProvider.family<StreakModel?, String>((ref, profileId) {
  return ref.watch(streakRepositoryProvider).fetchByProfile(profileId);
});

/// Log a learning activity for the profile and refresh the streak.
/// Call this when the user completes a card, review, or concept.
Future<void> logStreakActivity(WidgetRef ref, String profileId) async {
  await ref.read(streakRepositoryProvider).logActivity(profileId);
  ref.invalidate(streakProvider(profileId));
}
