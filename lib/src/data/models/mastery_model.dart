class MasteryModel {
  final String id;
  final String profileId;
  final String conceptId;
  final double masteryLevel;
  final int timesPracticed;
  final DateTime? lastPracticedAt;
  final DateTime? nextReviewAt;
  final double easeFactor;
  final int repetitionCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MasteryModel({
    required this.id,
    required this.profileId,
    required this.conceptId,
    this.masteryLevel = 0,
    this.timesPracticed = 0,
    this.lastPracticedAt,
    this.nextReviewAt,
    this.easeFactor = 2.5,
    this.repetitionCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory MasteryModel.fromJson(Map<String, dynamic> json) {
    return MasteryModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      conceptId: json['concept_id'] as String,
      masteryLevel: (json['mastery_level'] as num?)?.toDouble() ?? 0,
      timesPracticed: json['times_practiced'] as int? ?? 0,
      lastPracticedAt: json['last_practiced_at'] != null
          ? DateTime.parse(json['last_practiced_at'] as String)
          : null,
      nextReviewAt: json['next_review_at'] != null
          ? DateTime.parse(json['next_review_at'] as String)
          : null,
      easeFactor: (json['ease_factor'] as num?)?.toDouble() ?? 2.5,
      repetitionCount: json['repetition_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'profile_id': profileId,
        'concept_id': conceptId,
        'mastery_level': masteryLevel,
        'times_practiced': timesPracticed,
        'last_practiced_at': lastPracticedAt?.toIso8601String(),
        'next_review_at': nextReviewAt?.toIso8601String(),
        'ease_factor': easeFactor,
        'repetition_count': repetitionCount,
      };

  /// Whether the concept is due for review (next_review_at <= now)
  bool get isDueForReview =>
      nextReviewAt != null && nextReviewAt!.isBefore(DateTime.now());

  /// Human-readable mastery percentage
  String get masteryPercentage => '${(masteryLevel * 100).round()}%';

  /// Whether the user has "mastered" this concept (>= 80%)
  bool get isMastered => masteryLevel >= 0.8;
}
