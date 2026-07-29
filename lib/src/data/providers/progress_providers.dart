import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';

/// Count of concepts the user has interacted with
final conceptsCompletedProvider =
    FutureProvider.family<int, String>((ref, profileId) async {
  final client = ref.watch(supabaseProvider);
  try {
    final data = await client
        .from('object_interactions')
        .select('learning_object_id')
        .eq('profile_id', profileId)
        .eq('completed', true);
    // Count unique learning objects completed
    final ids = (data as List).map((e) => e['learning_object_id']).toSet();
    return ids.length;
  } catch (_) {
    return 0;
  }
});

/// Total learning time in minutes
final totalLearningTimeProvider =
    FutureProvider.family<int, String>((ref, profileId) async {
  final client = ref.watch(supabaseProvider);
  try {
    final data = await client
        .from('learning_sessions')
        .select('duration_seconds')
        .eq('profile_id', profileId);
    int total = 0;
    for (final row in (data as List)) {
      total += (row['duration_seconds'] as num?)?.toInt() ?? 0;
    }
    return (total / 60).ceil();
  } catch (_) {
    return 0;
  }
});

/// Count of concepts mastered (mastery_level > 0.7)
final conceptsMasteredProvider =
    FutureProvider.family<int, String>((ref, profileId) async {
  final client = ref.watch(supabaseProvider);
  try {
    final data = await client
        .from('mastery')
        .select('id')
        .eq('profile_id', profileId)
        .gte('mastery_level', 0.7);
    return (data as List).length;
  } catch (_) {
    return 0;
  }
});
