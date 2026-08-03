import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/core/services/llm_service.dart';
import 'package:rever/src/core/services/relationship_generator.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:rever/src/data/models/idea_relationship_model.dart';
import 'package:rever/src/data/providers/idea_card_providers.dart';
import 'package:rever/src/data/repositories/idea_relationship_repository.dart';

final ideaRelationshipRepositoryProvider =
    Provider<IdeaRelationshipRepository>((ref) {
  return IdeaRelationshipRepository(ref.watch(supabaseProvider));
});

final relationshipGeneratorProvider = Provider<RelationshipGenerator>((ref) {
  final llm = ref.watch(llmServiceProvider);
  return RelationshipGenerator(llm.complete);
});

/// Seed identifying the idea whose related ideas we want.
class RelatedSeed {
  final String? cardId;
  final String? sourceId;
  final String? conceptId;

  const RelatedSeed({this.cardId, this.sourceId, this.conceptId});

  @override
  bool operator ==(Object other) =>
      other is RelatedSeed &&
      other.cardId == cardId &&
      other.sourceId == sourceId &&
      other.conceptId == conceptId;

  @override
  int get hashCode => Object.hash(cardId, sourceId, conceptId);
}

/// Related ideas for the seed card. In dev the graph is derived locally from
/// stashed cards (same source / concept heuristic); in production it reads the
/// real `idea_relationships` edges from Supabase.
final relatedIdeasProvider =
    FutureProvider.family<List<RelatedIdea>, RelatedSeed>((ref, seed) async {
  if (AppEnvironment.isDev) {
    final cards = await ref.watch(localIdeaStoreProvider.future).then((s) {
      return s.loadAll();
    });
    return deriveRelatedIdeas(seed, cards);
  }
  final cardId = seed.cardId;
  if (cardId == null) return const [];
  return ref.watch(ideaRelationshipRepositoryProvider).fetchRelated(cardId);
});

/// Dev-mode heuristic: cards sharing the same source or concept are related
/// (no Supabase in dev, so the graph is derived locally, flow.txt §5 fallback).
List<RelatedIdea> deriveRelatedIdeas(RelatedSeed seed, List<IdeaCard> cards) {
  return [
    for (final card in cards)
      if (card.id != seed.cardId &&
          ((seed.sourceId != null && card.sourceId == seed.sourceId) ||
              (seed.conceptId != null && card.conceptId == seed.conceptId)))
        RelatedIdea(card: card, relationshipType: 'related_to')
  ];
}
