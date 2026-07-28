class LearningObjectModel {
  final String id;
  final String conceptId;
  final String objectType;
  final String title;
  final Map<String, dynamic> content;
  final String difficulty;
  final int? estimatedDuration;

  const LearningObjectModel({
    required this.id,
    required this.conceptId,
    required this.objectType,
    required this.title,
    required this.content,
    this.difficulty = 'beginner',
    this.estimatedDuration,
  });

  factory LearningObjectModel.fromJson(Map<String, dynamic> json) =>
      LearningObjectModel(
        id: json['id'] as String,
        conceptId: json['concept_id'] as String,
        objectType: json['object_type'] as String,
        title: json['title'] as String,
        content: Map<String, dynamic>.from(json['content'] as Map),
        difficulty: (json['difficulty'] as String?) ?? 'beginner',
        estimatedDuration: (json['estimated_duration'] as num?)?.toInt(),
      );
}
