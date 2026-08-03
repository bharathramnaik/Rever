/// A generated flashcard (Sprint 5, flow.txt §7).
class Flashcard {
  final String front;
  final String back;
  const Flashcard({required this.front, required this.back});

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        front: json['front'] as String? ?? '',
        back: json['back'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'front': front, 'back': back};
}

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
  final DateTime? createdAt;

  // Sprint 2: richer idea fields (flow.txt §1)
  final String? difficulty; // beginner | intermediate | advanced
  final double qualityScore;
  final String language;
  final String status; // draft | review | published | archived
  final List<String> tags;

  // Sprint 5: multi-asset knowledge (flow.txt §7)
  final List<String> takeaways;
  final List<String> examples;
  final List<String> questions;
  final List<Flashcard> flashcards;

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
    this.createdAt,
    this.difficulty,
    this.qualityScore = 0,
    this.language = 'en',
    this.status = 'published',
    this.tags = const [],
    this.takeaways = const [],
    this.examples = const [],
    this.questions = const [],
    this.flashcards = const [],
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
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        difficulty: json['difficulty'] as String?,
        qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 0,
        language: json['language'] as String? ?? 'en',
        status: json['status'] as String? ?? 'published',
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
        takeaways: (json['takeaways'] as List?)?.cast<String>() ?? const [],
        examples: (json['examples'] as List?)?.cast<String>() ?? const [],
        questions: (json['questions'] as List?)?.cast<String>() ?? const [],
        flashcards: (json['flashcards'] as List?)
                ?.map((f) => Flashcard.fromJson(f as Map<String, dynamic>))
                .toList() ??
            const [],
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
        'difficulty': difficulty,
        'quality_score': qualityScore,
        'language': language,
        'status': status,
        'tags': tags,
        'takeaways': takeaways,
        'examples': examples,
        'questions': questions,
        'flashcards': [for (final f in flashcards) f.toJson()],
      };
}
