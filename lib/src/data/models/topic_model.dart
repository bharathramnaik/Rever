class TopicModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? color;
  final int sortOrder;

  const TopicModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    this.color,
    this.sortOrder = 0,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) => TopicModel(
        id: json['id'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String?,
        icon: json['icon'] as String?,
        color: json['color'] as String?,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      );
}
