import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/models/preferences_model.dart';
import 'package:rever/src/data/repositories/preference_repository.dart';

final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) {
  return PreferenceRepository(ref.watch(supabaseProvider));
});

final preferencesProvider =
    FutureProvider.family<PreferencesModel?, String>((ref, profileId) {
  return ref.watch(preferenceRepositoryProvider).fetch(profileId);
});

final activePreferencesProvider = FutureProvider<PreferencesModel?>((ref) async {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return null;
  return ref.watch(preferencesProvider(profileId).future);
});
