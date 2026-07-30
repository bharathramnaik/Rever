class Quote {
  final String id;
  final String text;
  final String author;
  final String? source;
  final String? category;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    this.source,
    this.category,
  });

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        id: json['id'] as String,
        text: json['text'] as String,
        author: json['author'] as String,
        source: json['source'] as String?,
        category: json['category'] as String?,
      );
}
