class StreakModel {
  final String id;
  final String profileId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final int totalLearningDays;

  const StreakModel({
    required this.id,
    required this.profileId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.totalLearningDays = 0,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) => StreakModel(
        id: json['id'] as String,
        profileId: json['profile_id'] as String,
        currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
        longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
        lastActivityDate: json['last_activity_date'] != null
            ? DateTime.parse(json['last_activity_date'] as String)
            : null,
        totalLearningDays: (json['total_learning_days'] as num?)?.toInt() ?? 0,
      );
}
