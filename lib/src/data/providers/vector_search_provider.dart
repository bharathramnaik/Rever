import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/core/services/embedding_service.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:rever/src/data/providers/idea_card_providers.dart';

final embeddingClientProvider = Provider<EmbeddingClient?>((ref) {
  return EmbeddingClient.fromEnvironment();
});

/// A vector-search hit with its reranked score (flow.txt §4).
class VectorHit {
  final IdeaCard card;
  final double score;
  const VectorHit({required this.card, required this.score});
}

/// Reranking (flow.txt §4): blend similarity with the quality gate so that a
/// slightly less similar but better-written card can win.
double rerankScore(double similarity, double qualityScore) =>
    0.85 * similarity + 0.15 * qualityScore;

/// Keyword fallback: simple token containment over takeaway/body. Used in dev
/// (no embeddings) and when the embedding call fails (flow.txt §4 fallback).
List<VectorHit> keywordHits(String query, List<IdeaCard> cards) {
  final terms =
      query.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((t) => t.isNotEmpty);
  if (terms.isEmpty) return const [];
  final hits = <VectorHit>[];
  for (final card in cards) {
    final text = '${card.takeaway} ${card.body}'.toLowerCase();
    final matched = terms.where(text.contains).length;
    if (matched == 0) continue;
    hits.add(VectorHit(
      card: card,
      score: matched / terms.length,
    ));
  }
  hits.sort((a, b) => b.score.compareTo(a.score));
  return hits;
}

/// Vector search over idea cards. Production: NVIDIA NIM embedding + Supabase
/// `search_idea_embeddings` RPC, reranked. Dev / no key / failure: keyword
/// fallback over locally stashed cards.
final vectorSearchProvider =
    FutureProvider.family<List<VectorHit>, String>((ref, query) async {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];

  if (AppEnvironment.isDev) {
    final cards = await ref.watch(localIdeaStoreProvider.future).then((s) {
      return s.loadAll();
    });
    return keywordHits(q, cards);
  }

  final client = ref.watch(embeddingClientProvider);
  if (client == null) {
    final cards =
        await ref.watch(ideaCardRepositoryProvider).fetchFeed(limit: 50);
    return keywordHits(q, cards);
  }

  try {
    final vector = await client.embed(q);
    if (vector == null) {
      final cards =
          await ref.watch(ideaCardRepositoryProvider).fetchFeed(limit: 50);
      return keywordHits(q, cards);
    }
    final rows = await ref
        .watch(supabaseProvider)
        .rpc('search_idea_embeddings', params: {
      'query_embedding': vector,
      'match_count': 10,
    });
    final hits = <VectorHit>[];
    for (final row in rows as List) {
      final m = row as Map<String, dynamic>;
      final similarity = (m['similarity'] as num?)?.toDouble() ?? 0;
      final quality = (m['quality_score'] as num?)?.toDouble() ?? 0;
      hits.add(VectorHit(
        card: IdeaCard.fromJson({
          'id': m['id'],
          'takeaway': m['takeaway'],
          'body': m['body'],
          'quality_score': quality,
        }),
        score: rerankScore(similarity, quality),
      ));
    }
    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits;
  } catch (e) {
    final cards =
        await ref.watch(ideaCardRepositoryProvider).fetchFeed(limit: 50);
    return keywordHits(q, cards);
  }
});
