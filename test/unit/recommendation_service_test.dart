import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/core/services/recommendation_service.dart';
import 'package:rever/src/data/models/idea_card_model.dart';

IdeaCard card(
  String id, {
  String? source,
  List<String> tags = const [],
  int likes = 0,
  int mindBlown = 0,
  int actionable = 0,
  DateTime? createdAt,
}) =>
    IdeaCard(
      id: id,
      sourceId: source,
      takeaway: id,
      body: 'body',
      likeCount: likes,
      mindBlownCount: mindBlown,
      actionableCount: actionable,
      createdAt: createdAt,
      tags: tags,
    );

void main() {
  final svc = RecommendationService();
  final now = DateTime(2026, 8, 4);

  test('trend score monotonic in engagement', () {
    final low = svc.trendScore(card('a'));
    final mid = svc.trendScore(card('b', likes: 8));
    final high = svc.trendScore(card('c', likes: 100, mindBlown: 50));
    expect(low, lessThan(mid));
    expect(mid, lessThan(high));
    expect(low, inInclusiveRange(0, 1));
    expect(high, inInclusiveRange(0, 1));
  });

  test('freshness decays with age', () {
    final fresh = svc.freshnessScore(
        card('a', createdAt: now.subtract(const Duration(days: 1))), now);
    final old = svc.freshnessScore(
        card('b', createdAt: now.subtract(const Duration(days: 300))), now);
    expect(fresh, greaterThan(old));
    expect(old, closeTo(0, 0.05));
  });

  test('null createdAt -> freshness 0', () {
    expect(svc.freshnessScore(card('a'), now), 0);
  });

  test('personalization = tag overlap fraction', () {
    final c = card('a', tags: ['habits', 'focus', 'productivity']);
    expect(svc.personalizationScore(c, {'habits'}), closeTo(1 / 3, 0.001));
    expect(svc.personalizationScore(c, {'habits', 'focus'}), closeTo(2 / 3, 0.001));
    expect(svc.personalizationScore(c, {'unrelated'}), 0);
    expect(svc.personalizationScore(c, {}), 0);
    expect(svc.personalizationScore(card('b'), {'habits'}), 0);
  });

  test('diversity penalizes repeated sources', () {
    final seen = <String, int>{};
    expect(svc.diversityScore('s1', seen), 1.0);
    seen['s1'] = 1;
    expect(svc.diversityScore('s1', seen), 0.2);
    seen['s1'] = 2;
    expect(svc.diversityScore('s1', seen), 0.05);
  });

  test('ranking favors preferred tags + engagement', () {
    final c1 = card('popular', tags: ['habits'], likes: 100);
    final c2 = card('matched', tags: ['habits'], likes: 1);
    final c3 = card('unmatched', tags: ['other'], likes: 100);
    final ranked = svc.scoreAndRank([c1, c2, c3], prefs: {'habits'});
    expect(ranked.first.card.id, 'popular');
    expect(ranked.last.card.id, 'unmatched');
  });

  test('diversity caps same-source cards at 2', () {
    final ranked = svc.scoreAndRank([
      card('a', source: 'book-1', likes: 5),
      card('b', source: 'book-1', likes: 5),
      card('c', source: 'book-1', likes: 5),
      card('d', source: 'book-2', likes: 5),
    ]);
    final book1Count =
        ranked.where((s) => s.card.sourceId == 'book-1').length;
    expect(book1Count, lessThanOrEqualTo(2));
    expect(ranked.length, 3);
  });

  test('empty cards -> empty result', () {
    expect(svc.scoreAndRank([]), isEmpty);
  });
}
