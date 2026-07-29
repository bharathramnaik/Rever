import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/concept_relationship_model.dart';
import 'package:rever/src/data/models/concept_model.dart';

/// Fetch all relationships where this concept is either source or target
final conceptRelationshipsProvider = FutureProvider.family<
    List<ConceptRelationshipModel>, String>((ref, conceptId) async {
  final client = ref.watch(supabaseProvider);
  final data = await client
      .from('concept_relationships')
      .select()
      .or('source_concept_id.eq.$conceptId,target_concept_id.eq.$conceptId');
  return (data as List)
      .map((e) => ConceptRelationshipModel.fromJson(e))
      .toList();
});

/// Fetch related concepts (resolved to full ConceptModel) for a concept
final relatedConceptsProvider =
    FutureProvider.family<List<RelatedConcept>, String>((ref, conceptId) async {
  final client = ref.watch(supabaseProvider);

  // Get all relationships
  final relData = await client
      .from('concept_relationships')
      .select()
      .or('source_concept_id.eq.$conceptId,target_concept_id.eq.$conceptId');

  if ((relData as List).isEmpty) return [];

  final relationships = relData
      .map((e) => ConceptRelationshipModel.fromJson(e))
      .toList();

  // Collect related concept IDs
  final relatedIds = <String>{};
  for (final r in relationships) {
    if (r.sourceConceptId == conceptId) {
      relatedIds.add(r.targetConceptId);
    } else {
      relatedIds.add(r.sourceConceptId);
    }
  }

  if (relatedIds.isEmpty) return [];

  // Fetch the concepts
  final conceptData = await client
      .from('concepts')
      .select()
      .inFilter('id', relatedIds.toList());
  final concepts = (conceptData as List)
      .map((e) => ConceptModel.fromJson(e))
      .toList();

  // Build result with relationship type
  final result = <RelatedConcept>[];
  for (final r in relationships) {
    final otherId = r.sourceConceptId == conceptId
        ? r.targetConceptId
        : r.sourceConceptId;
    final concept = concepts.where((c) => c.id == otherId).firstOrNull;
    if (concept != null) {
      result.add(RelatedConcept(
        concept: concept,
        relationship: r,
        isSource: r.sourceConceptId == conceptId,
      ));
    }
  }

  return result;
});

/// A concept with its relationship context
class RelatedConcept {
  final ConceptModel concept;
  final ConceptRelationshipModel relationship;
  final bool isSource; // true if the current concept is the source

  const RelatedConcept({
    required this.concept,
    required this.relationship,
    required this.isSource,
  });

  /// Direction-aware label: "Prerequisite of X" vs "X is prerequisite"
  String get label {
    return isSource
        ? '${relationship.typeLabel} → ${concept.title}'
        : '${concept.title} → ${relationship.typeLabel}';
  }
}
