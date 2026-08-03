import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/core/services/recommendation_service.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:rever/src/data/providers/idea_card_providers.dart';
import 'package:rever/src/data/providers/preferences_provider.dart';

/// Ranked idea feed (flow.txt §3). Dev: scores local stash cards (no
/// Supabase). Production: scores the feed from Supabase.
final scoredFeedProvider = FutureProvider<List<ScoredIdea>>((ref) async {
  final prefs = ref.watch(activePreferencesProvider).asData?.value;
  final topics = prefs?.topics ?? const <String>[];

  final List<IdeaCard> cards;
  if (AppEnvironment.isDev) {
    cards = await ref.watch(localIdeaStoreProvider.future).then((s) {
      return s.loadAll();
    });
  } else {
    cards = await ref.watch(ideaCardRepositoryProvider).fetchFeed(limit: 20);
  }
  if (cards.isEmpty) return const [];
  return RecommendationService()
      .scoreAndRank(cards, prefs: topics.toSet());
});
