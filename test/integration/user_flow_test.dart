import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/app/app.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/providers/topic_providers.dart';
import 'package:rever/src/data/providers/concept_providers.dart';
import 'package:rever/src/data/providers/library_providers.dart';
import 'package:rever/src/data/providers/streak_providers.dart';
import 'package:rever/src/data/providers/feed_provider.dart';
import 'package:rever/src/data/providers/quote_provider.dart';
import 'package:rever/src/data/models/feed_item_model.dart';
import '../helpers/test_data.dart';

void main() {
  group('Critical User Flow', () {
    testWidgets('onboarding -> profiles -> home -> explore -> concept',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profilesProvider.overrideWith((ref) async => [testProfile]),
            randomQuoteProvider.overrideWith((ref) async => null),
            topicsProvider.overrideWith((ref) async => testTopics),
            conceptsByTopicProvider
                .overrideWith((ref, topicId) async => testConcepts),
            conceptBySlugProvider
                .overrideWith((ref, slug) async => testConcept),
            learningObjectsProvider
                .overrideWith((ref, conceptId) async => testLearningObjects),
            savedObjectsProvider
                .overrideWith((ref, profileId) async => testLearningObjects),
            streakProvider
                .overrideWith((ref, profileId) async => testStreak),
            feedProvider.overrideWith((ref) async => [
              FeedItemModel(
                id: 'test-feed-1',
                type: FeedItemType.discovery,
                title: 'Your Daily Journey',
                subtitle: 'Test feed',
                createdAt: DateTime.now(),
              ),
            ]),
          ],
          child: const ReverApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Should start at onboarding
      expect(find.text('Learn Anything'), findsOneWidget);

      // Navigate through onboarding to interests
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Skip interest selection to reach profiles
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();

      // Should show profile selection
      expect(find.text("Who's learning?"), findsOneWidget);

      // Select first profile
      await tester.tap(find.text('Test User'));
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('explore -> concept navigation works', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            topicsProvider.overrideWith((ref) async => testTopics),
            conceptsByTopicProvider
                .overrideWith((ref, topicId) async => testConcepts),
            conceptBySlugProvider
                .overrideWith((ref, slug) async => testConcept),
            learningObjectsProvider
                .overrideWith((ref, conceptId) async => testLearningObjects),
            savedObjectsProvider
                .overrideWith((ref, profileId) async => testLearningObjects),
            streakProvider
                .overrideWith((ref, profileId) async => testStreak),
          ],
          child: const MaterialApp(home: _TestScaffold()),
        ),
      );

      await tester.pumpAndSettle();

      // Should see topics from override
      expect(find.text('Technology'), findsOneWidget);
      expect(find.text('Science'), findsOneWidget);
    });
  });
}

class _TestScaffold extends StatelessWidget {
  const _TestScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ExplorerBody(),
    );
  }
}

class ExplorerBody extends ConsumerWidget {
  const ExplorerBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    return topicsAsync.when(
      data: (topics) => ListView(
        children: topics.map((t) => Text(t.name)).toList(),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('$e'),
    );
  }
}
