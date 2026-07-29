import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/mastery_model.dart';

/// Fetch mastery records for a profile
final masteryByProfileProvider =
    FutureProvider.family<List<MasteryModel>, String>((ref, profileId) async {
  final client = ref.watch(supabaseProvider);
  final data = await client
      .from('mastery')
      .select()
      .eq('profile_id', profileId)
      .order('updated_at', ascending: false);
  return (data as List).map((e) => MasteryModel.fromJson(e)).toList();
});

/// Fetch mastery for a specific concept for a profile
final conceptMasteryProvider =
    FutureProvider.family<MasteryModel?, ({String profileId, String conceptId})>(
        (ref, params) async {
  final client = ref.watch(supabaseProvider);
  final data = await client
      .from('mastery')
      .select()
      .eq('profile_id', params.profileId)
      .eq('concept_id', params.conceptId)
      .maybeSingle();
  if (data == null) return null;
  return MasteryModel.fromJson(data);
});

/// Fetch concepts due for review
final dueForReviewProvider =
    FutureProvider.family<List<MasteryModel>, String>((ref, profileId) async {
  final client = ref.watch(supabaseProvider);
  final now = DateTime.now().toIso8601String();
  final data = await client
      .from('mastery')
      .select()
      .eq('profile_id', profileId)
      .lte('next_review_at', now)
      .order('next_review_at', ascending: true);
  return (data as List).map((e) => MasteryModel.fromJson(e)).toList();
});
