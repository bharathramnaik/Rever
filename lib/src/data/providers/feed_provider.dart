import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/providers/topic_providers.dart';
import 'package:rever/src/data/providers/concept_providers.dart';
import 'package:rever/src/data/models/feed_item_model.dart';

final feedProvider = FutureProvider<List<FeedItemModel>>((ref) async {
  final topics = await ref.watch(topicsProvider.future);
  final concepts = await ref.watch(allConceptsProvider.future);

  final items = <FeedItemModel>[];
  var id = 0;

  items.add(FeedItemModel(
    id: 'feed-daily-${++id}',
    type: FeedItemType.discovery,
    title: 'Your Daily Journey',
    subtitle: '3 concepts to explore today',
    createdAt: DateTime.now(),
  ));

  for (final topic in topics.take(4)) {
    items.add(FeedItemModel(
      id: 'feed-topic-${topic.id}',
      type: FeedItemType.insight,
      title: topic.name,
      subtitle: topic.description,
      metadata: {'slug': topic.slug, 'color': topic.color, 'icon': topic.icon},
      createdAt: DateTime.now(),
    ));
  }

  for (final concept in concepts.take(4)) {
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

  if (concepts.length >= 2) {
    items.insert(3, FeedItemModel(
      id: 'feed-question-${++id}',
      type: FeedItemType.question,
      title: 'Do you understand ${concepts[0].title}?',
      subtitle: 'Test your knowledge with a quick question',
      metadata: {'concept_slug': concepts[0].slug},
      createdAt: DateTime.now(),
    ));
  }

  items.add(FeedItemModel(
    id: 'feed-challenge-${++id}',
    type: FeedItemType.challenge,
    title: '7-Day Streak Challenge',
    subtitle: 'Learn something new every day this week',
    createdAt: DateTime.now(),
  ));

  return items;
});
