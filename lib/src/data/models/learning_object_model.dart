class LearningObjectModel {
  final String id;
  final String conceptId;
  final String objectType;
  final String title;
  final Map<String, dynamic> content;
  final String difficulty;
  final int? estimatedDuration;
  final int? depthLevel;

  const LearningObjectModel({
    required this.id,
    required this.conceptId,
    required this.objectType,
    required this.title,
    required this.content,
    this.difficulty = 'beginner',
    this.estimatedDuration,
    this.depthLevel,
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
        depthLevel: json['depth_level'] as int?,
      );

  int get inferredDepth {
    if (depthLevel != null) return depthLevel!;
    switch (objectType) {
      case 'card':
      case 'insight':
        return 1;
      case 'article':
      case 'explanation':
      case 'story':
        return 2;
      case 'diagram':
      case 'flowchart':
      case 'timeline':
        return 3;
      case 'quiz':
      case 'flashcard':
      case 'exercise':
        return 4;
      case 'project':
        return 5;
      default:
        return 2;
    }
  }
}
