class ProfileModel {
  final String id;
  final String accountId;
  final String name;
  final String? avatarUrl;
  final String profileType;
  final String? ageRange;
  final int dailyGoalMinutes;

  const ProfileModel({
    required this.id,
    required this.accountId,
    required this.name,
    this.avatarUrl,
    this.profileType = 'adult',
    this.ageRange,
    this.dailyGoalMinutes = 10,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        accountId: json['account_id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatar_url'] as String?,
        profileType: (json['profile_type'] as String?) ?? 'adult',
        ageRange: json['age_range'] as String?,
        dailyGoalMinutes: (json['daily_goal_minutes'] as num?)?.toInt() ?? 10,
      );
}
