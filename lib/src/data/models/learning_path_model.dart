class LearningPathModel {
  final String id;
  final String title;
  final String? description;
  final String? topicId;
  final String difficulty;
  final int? estimatedTotalMinutes;
  final DateTime? createdAt;

  const LearningPathModel({
    required this.id,
    required this.title,
    this.description,
    this.topicId,
    this.difficulty = 'beginner',
    this.estimatedTotalMinutes,
    this.createdAt,
  });

  factory LearningPathModel.fromJson(Map<String, dynamic> json) {
    return LearningPathModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      topicId: json['topic_id'] as String?,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      estimatedTotalMinutes: json['estimated_total_minutes'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'topic_id': topicId,
        'difficulty': difficulty,
        'estimated_total_minutes': estimatedTotalMinutes,
      };
}

class LearningPathStepModel {
  final String id;
  final String pathId;
  final String learningObjectId;
  final int stepOrder;
  final bool required;

  const LearningPathStepModel({
    required this.id,
    required this.pathId,
    required this.learningObjectId,
    required this.stepOrder,
    this.required = true,
  });

  factory LearningPathStepModel.fromJson(Map<String, dynamic> json) {
    return LearningPathStepModel(
      id: json['id'] as String,
      pathId: json['path_id'] as String,
      learningObjectId: json['learning_object_id'] as String,
      stepOrder: json['step_order'] as int,
      required: json['required'] as bool? ?? true,
    );
  }
}
