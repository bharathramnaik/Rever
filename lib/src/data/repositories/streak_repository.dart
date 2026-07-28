import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rever/src/data/models/streak_model.dart';

class StreakRepository {
  final SupabaseClient _client;
  StreakRepository(this._client);

  Future<StreakModel?> fetchByProfile(String profileId) async {
    final data = await _client
        .from('streaks')
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();
    if (data == null) return null;
    return StreakModel.fromJson(data);
  }

  Future<void> logActivity(String profileId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final existing = await _client
        .from('streaks')
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();
    if (existing == null) {
      await _client.from('streaks').insert({
        'profile_id': profileId,
        'current_streak': 1,
        'longest_streak': 1,
        'last_activity_date': today,
        'total_learning_days': 1,
      });
      return;
    }
    final streak = StreakModel.fromJson(existing);
    final lastDate = streak.lastActivityDate;
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);
    final isConsecutive = lastDate != null &&
        (lastDate.toIso8601String().substring(0, 10) == yesterday ||
            lastDate.toIso8601String().substring(0, 10) == today);
    final newStreak = isConsecutive ? streak.currentStreak + 1 : 1;
    await _client.from('streaks').update({
      'current_streak': newStreak,
      'longest_streak': newStreak > streak.longestStreak
          ? newStreak
          : streak.longestStreak,
      'last_activity_date': today,
      'total_learning_days': streak.totalLearningDays + 1,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('profile_id', profileId);
  }
}
