class IdeaCard {
  final String id;
  final String? sourceId;
  final String? conceptId;
  final String takeaway;
  final String body;
  final String? quote;
  final String? audioUrl;
  final int likeCount;
  final int mindBlownCount;
  final int actionableCount;

  const IdeaCard({
    required this.id,
    this.sourceId,
    this.conceptId,
    required this.takeaway,
    required this.body,
    this.quote,
    this.audioUrl,
    this.likeCount = 0,
    this.mindBlownCount = 0,
    this.actionableCount = 0,
  });

  factory IdeaCard.fromJson(Map<String, dynamic> json) => IdeaCard(
        id: json['id'] as String,
        sourceId: json['source_id'] as String?,
        conceptId: json['concept_id'] as String?,
        takeaway: json['takeaway'] as String? ?? '',
        body: json['body'] as String? ?? '',
        quote: json['quote'] as String?,
        audioUrl: json['audio_url'] as String?,
        likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
        mindBlownCount: (json['mind_blown_count'] as num?)?.toInt() ?? 0,
        actionableCount: (json['actionable_count'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'source_id': sourceId,
        'concept_id': conceptId,
        'takeaway': takeaway,
        'body': body,
        'quote': quote,
        'audio_url': audioUrl,
        'like_count': likeCount,
        'mind_blown_count': mindBlownCount,
        'actionable_count': actionableCount,
      };
}
