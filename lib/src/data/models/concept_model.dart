class ConceptModel {
  final String id;
  final String title;
  final String slug;
  final String? summary;
  final String difficulty;
  final int? estimatedMinutes;
  final DateTime createdAt;

  const ConceptModel({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    this.difficulty = 'beginner',
    this.estimatedMinutes,
    required this.createdAt,
  });

  factory ConceptModel.fromJson(Map<String, dynamic> json) => ConceptModel(
        id: json['id'] as String,
        title: json['title'] as String,
        slug: json['slug'] as String,
        summary: json['summary'] as String?,
        difficulty: (json['difficulty'] as String?) ?? 'beginner',
        estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
