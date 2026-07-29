import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/providers/topic_providers.dart';
import 'package:rever/src/data/providers/concept_providers.dart';
import 'package:rever/src/data/models/feed_item_model.dart';

final feedProvider = FutureProvider<List<FeedItemModel>>((ref) async {
  final topics = await ref.watch(topicsProvider.future);
  final concepts = await ref.watch(allConceptsProvider.future);

  final items = <FeedItemModel>[];
  var id = 0;

  // Daily Journey card
  items.add(FeedItemModel(
    id: 'feed-daily-${++id}',
    type: FeedItemType.discovery,
    title: 'Your Daily Journey',
    subtitle: '${concepts.take(3).length} concepts to explore today',
    createdAt: DateTime.now(),
  ));

  // First 2 topic insights
  for (final topic in topics.take(2)) {
    items.add(FeedItemModel(
      id: 'feed-topic-${topic.id}',
      type: FeedItemType.insight,
      title: topic.name,
      subtitle: topic.description,
      metadata: {'slug': topic.slug, 'color': topic.color, 'icon': topic.icon},
      createdAt: DateTime.now(),
    ));
  }

  // Learning path suggestion
  if (topics.length >= 2) {
    items.add(FeedItemModel(
      id: 'feed-path-${++id}',
      type: FeedItemType.learningPath,
      title: 'AI for Beginners',
      subtitle: '5 concepts • 30 min • Start your journey into AI',
      metadata: {'slug': 'technology'},
      createdAt: DateTime.now(),
    ));
  }

  // Mix of concepts with better interleaving
  for (final concept in concepts.take(3)) {
    items.add(FeedItemModel(
      id: 'feed-concept-${concept.id}',
      type: FeedItemType.concept,
      title: concept.title,
      subtitle: concept.summary,
      metadata: {
        'slug': concept.slug,
        'difficulty': concept.difficulty,
        'minutes': concept.estimatedMinutes,
      },
      createdAt: DateTime.now(),
    ));
  }

  // Question card
  if (concepts.length >= 2) {
    items.insert(5, FeedItemModel(
      id: 'feed-question-${++id}',
      type: FeedItemType.question,
      title: 'Do you understand ${concepts[0].title}?',
      subtitle: 'Test your knowledge with a quick quiz',
      metadata: {'concept_slug': concepts[0].slug},
      createdAt: DateTime.now(),
    ));
  }

  // Review reminder (spaced repetition)
  items.add(FeedItemModel(
    id: 'feed-review-${++id}',
    type: FeedItemType.review,
    title: 'Time to review',
    subtitle: 'Strengthen your memory on concepts you\'ve learned',
    metadata: {
      'concept_slug': concepts.isNotEmpty ? concepts[0].slug : null,
    },
    createdAt: DateTime.now(),
  ));

  // More concepts
  for (final concept in concepts.skip(3).take(2)) {
    items.add(FeedItemModel(
      id: 'feed-concept-${concept.id}',
      type: FeedItemType.concept,
      title: concept.title,
      subtitle: concept.summary,
      metadata: {
        'slug': concept.slug,
        'difficulty': concept.difficulty,
        'minutes': concept.estimatedMinutes,
      },
      createdAt: DateTime.now(),
    ));
  }

  // Visual learning card
  items.add(FeedItemModel(
    id: 'feed-visual-${++id}',
    type: FeedItemType.visual,
    title: 'How the Internet Works — Visual Guide',
    subtitle: 'See how data packets travel across the global network',
    metadata: {'slug': 'how-internet-works'},
    createdAt: DateTime.now(),
  ));

  // More topic insights
  for (final topic in topics.skip(2).take(3)) {
    items.add(FeedItemModel(
      id: 'feed-topic-${topic.id}',
      type: FeedItemType.insight,
      title: topic.name,
      subtitle: topic.description,
      metadata: {'slug': topic.slug, 'color': topic.color, 'icon': topic.icon},
      createdAt: DateTime.now(),
    ));
  }

  // Challenge card at the end
  items.add(FeedItemModel(
    id: 'feed-challenge-${++id}',
    type: FeedItemType.challenge,
    title: '7-Day Streak Challenge',
    subtitle: 'Learn something new every day this week',
    createdAt: DateTime.now(),
  ));

  return items;
});
