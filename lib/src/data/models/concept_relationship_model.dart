class ConceptRelationshipModel {
  final String id;
  final String sourceConceptId;
  final String targetConceptId;
  final String relationshipType;
  final DateTime? createdAt;

  const ConceptRelationshipModel({
    required this.id,
    required this.sourceConceptId,
    required this.targetConceptId,
    required this.relationshipType,
    this.createdAt,
  });

  factory ConceptRelationshipModel.fromJson(Map<String, dynamic> json) {
    return ConceptRelationshipModel(
      id: json['id'] as String,
      sourceConceptId: json['source_concept_id'] as String,
      targetConceptId: json['target_concept_id'] as String,
      relationshipType: json['relationship_type'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source_concept_id': sourceConceptId,
        'target_concept_id': targetConceptId,
        'relationship_type': relationshipType,
      };

  /// Human-readable label for the relationship type
  String get typeLabel => switch (relationshipType) {
        'prerequisite_of' => 'Prerequisite',
        'related_to' => 'Related',
        'example_of' => 'Example',
        'part_of' => 'Part of',
        'extends' => 'Extends',
        'applies_to' => 'Applies to',
        'similar_to' => 'Similar',
        _ => relationshipType,
      };
}
