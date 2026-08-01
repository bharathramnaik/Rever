enum ContentSource { book, article }

class ExploreContent {
  final String id;
  final String title;
  final String? description;
  final String? fullContent;
  final String? thumbnailUrl;
  final ContentSource source;
  final String? author;
  final String? url;
  final String? category;
  final List<String> subjects;
  final List<String> keyPoints;

  const ExploreContent({
    required this.id,
    required this.title,
    this.description,
    this.fullContent,
    this.thumbnailUrl,
    required this.source,
    this.author,
    this.url,
    this.category,
    this.subjects = const [],
    this.keyPoints = const [],
  });

  String get sourceLabel => source == ContentSource.book ? 'BOOK' : 'ARTICLE';
}
