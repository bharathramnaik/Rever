import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rever/src/core/services/relationship_generator.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:rever/src/data/models/idea_relationship_model.dart';

class IdeaRelationshipRepository {
  final SupabaseClient _client;
  IdeaRelationshipRepository(this._client);

  /// Cards connected to [cardId] in either direction, each with its edge type
  /// and confidence.
  Future<List<RelatedIdea>> fetchRelated(String cardId) async {
    final edges = await _client
        .from('idea_relationships')
        .select('source_idea_id, target_idea_id, relationship_type, confidence')
        .or('source_idea_id.eq.$cardId,target_idea_id.eq.$cardId')
        .limit(50);
    final relatedIds = <String>[];
    final labels = <String, String>{};
    final confidences = <String, double>{};
    for (final e in edges as List) {
      final source = e['source_idea_id'] as String;
      final target = e['target_idea_id'] as String;
      final type = e['relationship_type'] as String;
      final confidence = (e['confidence'] as num?)?.toDouble() ?? 0.5;
      final other = source == cardId ? target : source;
      if (!relatedIds.contains(other)) relatedIds.add(other);
      labels[other] = type;
      confidences[other] = confidence;
    }
    if (relatedIds.isEmpty) return const [];

    final data = await _client
        .from('idea_cards')
        .select()
        .inFilter('id', relatedIds)
        .limit(50);
    final cards = <String, IdeaCard>{
      for (final row in data as List)
        row['id'] as String: IdeaCard.fromJson(row as Map<String, dynamic>),
    };
    return [
      for (final id in relatedIds)
        if (cards[id] != null)
          RelatedIdea(
            card: cards[id]!,
            relationshipType: labels[id] ?? 'related_to',
            confidence: confidences[id] ?? 0.5,
          ),
    ];
  }

  /// Persist generated edges (AI-curated graph). Called in non-dev mode only.
  Future<void> insertGenerated(
    String sourceIdeaId,
    List<GeneratedEdge> edges,
    List<String> candidateIds,
  ) async {
    for (final e in edges) {
      if (e.targetIndex < 0 || e.targetIndex >= candidateIds.length) continue;
      final targetId = candidateIds[e.targetIndex];
      if (targetId == sourceIdeaId) continue;
      await _client.from('idea_relationships').insert({
        'source_idea_id': sourceIdeaId,
        'target_idea_id': targetId,
        'relationship_type': e.type,
        'confidence': e.confidence,
      }).then((_) {}).catchError((_) => null); // unique-violation tolerant
    }
  }
}
