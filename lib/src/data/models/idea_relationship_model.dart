import 'package:rever/src/data/models/idea_card_model.dart';

/// A directional edge in the idea knowledge graph (flow.txt §5).
class IdeaRelationshipModel {
  final String id;
  final String sourceIdeaId;
  final String targetIdeaId;
  final String relationshipType;
  final double confidence;
  final DateTime? createdAt;

  const IdeaRelationshipModel({
    required this.id,
    required this.sourceIdeaId,
    required this.targetIdeaId,
    required this.relationshipType,
    this.confidence = 0.5,
    this.createdAt,
  });

  factory IdeaRelationshipModel.fromJson(Map<String, dynamic> json) {
    return IdeaRelationshipModel(
      id: json['id'] as String,
      sourceIdeaId: json['source_idea_id'] as String,
      targetIdeaId: json['target_idea_id'] as String,
      relationshipType: json['relationship_type'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'source_idea_id': sourceIdeaId,
        'target_idea_id': targetIdeaId,
        'relationship_type': relationshipType,
        'confidence': confidence,
      };

  /// Human-readable label for the relationship type.
  String get typeLabel => switch (relationshipType) {
        'supports' => 'Supports',
        'contradicts' => 'Contradicts',
        'prerequisite_of' => 'Prerequisite',
        'related_to' => 'Related',
        'example_of' => 'Example',
        'applies_to' => 'Applies to',
        _ => relationshipType,
      };
}

/// A related idea card together with the edge describing the relationship.
class RelatedIdea {
  final IdeaCard card;
  final String relationshipType;
  final double confidence;

  const RelatedIdea({
    required this.card,
    required this.relationshipType,
    this.confidence = 0.5,
  });

  String get typeLabel => switch (relationshipType) {
        'supports' => 'Supports',
        'contradicts' => 'Contradicts',
        'prerequisite_of' => 'Prerequisite of',
        'related_to' => 'Related',
        'example_of' => 'Example',
        'applies_to' => 'Applies to',
        _ => relationshipType,
      };
}
