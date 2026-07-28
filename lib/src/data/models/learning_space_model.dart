class LearningSpaceModel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  const LearningSpaceModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory LearningSpaceModel.fromJson(Map<String, dynamic> json) =>
      LearningSpaceModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
