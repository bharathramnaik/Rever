import 'dart:math' as math;

import 'package:rever/src/data/models/idea_card_model.dart';

/// A ranked idea with its score components (flow.txt §3).
class ScoredIdea {
  final IdeaCard card;
  final double trendScore;
  final double freshnessScore;
  final double personalizationScore;
  final double diversityScore;
  final double finalScore;

  const ScoredIdea({
    required this.card,
    required this.trendScore,
    required this.freshnessScore,
    required this.personalizationScore,
    required this.diversityScore,
    required this.finalScore,
  });
}

/// Weighted recommendation engine (flow.txt §3):
/// Final = 0.35*CF(engagement) + 0.30*personalization(tag match) +
///         0.20*trending + 0.10*freshness + 0.05*diversity.
/// Pure functions -> unit-testable without network.
class RecommendationService {
  static const wCf = 0.35;
  static const wPersonalization = 0.30;
  static const wTrending = 0.20;
  static const wFreshness = 0.10;
  static const wDiversity = 0.05;

  /// Collaborative-filtering proxy: normalized engagement (likes carry more
  /// weight than reactions, mind-blown most). Logistic so scores stay in 0..1.
  double trendScore(IdeaCard card) {
    final engagement =
        card.likeCount + 2 * card.mindBlownCount + 1.5 * card.actionableCount;
    return 1 - 1 / (1 + engagement / 8);
  }

  /// Freshness: exponential decay over 30 days.
  double freshnessScore(IdeaCard card, DateTime now) {
    final createdAt = card.createdAt;
    if (createdAt == null) return 0;
    final ageDays = now.difference(createdAt).inMinutes / (60 * 24);
    if (ageDays < 0) return 1;
    return math.exp(-ageDays / 30);
  }

  /// Personalization: fraction of the card's tags covered by the profile's
  /// topic preferences.
  double personalizationScore(IdeaCard card, Set<String> prefs) {
    if (prefs.isEmpty || card.tags.isEmpty) return 0;
    final matched = card.tags.where(prefs.contains).length;
    return matched / card.tags.length;
  }

  /// Diversity: 1.0 for a fresh source, 0.2 for a source already picked once,
  /// 0.05 for a source picked twice (cap at 2 per source).
  double diversityScore(String? sourceId, Map<String, int> seenSources) {
    final key = sourceId ?? '';
    final count = seenSources[key] ?? 0;
    if (count == 0) return 1.0;
    if (count == 1) return 0.2;
    return 0.05;
  }

  /// Ranks cards by the weighted score with a greedy diversity cap.
  List<ScoredIdea> scoreAndRank(
    List<IdeaCard> cards, {
    Set<String> prefs = const {},
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final seen = <String, int>{};

    final scored = cards.map((card) {
      final trend = trendScore(card);
      final fresh = freshnessScore(card, ref);
      final personal = personalizationScore(card, prefs);
      final diversity = diversityScore(card.sourceId, seen);
      final finalScore = wCf * trend +
          wPersonalization * personal +
          wTrending * trend +
          wFreshness * fresh +
          wDiversity * diversity;
      return ScoredIdea(
        card: card,
        trendScore: trend,
        freshnessScore: fresh,
        personalizationScore: personal,
        diversityScore: diversity,
        finalScore: finalScore,
      );
    }).toList()
      ..sort((a, b) => b.finalScore.compareTo(a.finalScore));

    final ranked = <ScoredIdea>[];
    for (final idea in scored) {
      final key = idea.card.sourceId ?? '';
      if ((seen[key] ?? 0) >= 2) continue; // diversity cap
      seen[key] = (seen[key] ?? 0) + 1;
      ranked.add(idea);
    }
    return ranked;
  }
}
