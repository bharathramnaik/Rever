import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/data/providers/topic_providers.dart';
import 'package:rever/src/data/providers/concept_providers.dart';

class TopicScreen extends ConsumerWidget {
  final String slug;

  const TopicScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final topicAsync = ref.watch(topicBySlugProvider(slug));

    return Scaffold(
      appBar: AppBar(
        title: topicAsync.when(
          data: (t) => Text(t?.name ?? 'Topic'),
          loading: () => const Text('Loading...'),
          error: (e, _) => const Text('Error'),
        ),
      ),
      body: topicAsync.when(
        data: (topic) {
          if (topic == null) {
            return const Center(child: Text('Topic not found'));
          }
          return _TopicContent(topicId: topic.id, theme: theme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _TopicContent extends ConsumerWidget {
  final String topicId;
  final ThemeData theme;

  const _TopicContent({required this.topicId, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptsAsync = ref.watch(conceptsByTopicProvider(topicId));

    return conceptsAsync.when(
      data: (concepts) {
        if (concepts.isEmpty) {
          return const Center(child: Text('No concepts available yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: concepts.length,
          itemBuilder: (context, index) {
            final concept = concepts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  concept.title,
                  style: theme.textTheme.titleLarge,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (concept.summary != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        concept.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            concept.difficulty[0].toUpperCase() +
                                concept.difficulty.substring(1),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        if (concept.estimatedMinutes != null)
                          Text(
                            '${concept.estimatedMinutes} min',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/concept/${concept.slug}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }
}
