enum FeedItemType {
  insight,
  concept,
  question,
  visual,
  story,
  review,
  challenge,
  source,
  learningPath,
  discovery,
}

class FeedItemModel {
  final String id;
  final FeedItemType type;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const FeedItemModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.metadata,
    required this.createdAt,
  });
}
