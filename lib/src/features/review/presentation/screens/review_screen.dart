import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/data/providers/concept_providers.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final conceptsAsync = ref.watch(allConceptsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Review', style: theme.textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Strengthen your memory with spaced repetition',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Review stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ReviewStat(
                      theme: theme,
                      icon: Icons.replay,
                      value: '0',
                      label: 'Due Today',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.colorScheme.outline,
                    ),
                    _ReviewStat(
                      theme: theme,
                      icon: Icons.check_circle_outline,
                      value: '0',
                      label: 'Reviewed',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: theme.colorScheme.outline,
                    ),
                    _ReviewStat(
                      theme: theme,
                      icon: Icons.trending_up,
                      value: '0%',
                      label: 'Accuracy',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Review content
              Expanded(
                child: conceptsAsync.when(
                  data: (concepts) {
                    if (concepts.isEmpty) {
                      return _EmptyReview(theme: theme);
                    }
                    // Show concepts available for review
                    return ListView.builder(
                      itemCount: concepts.take(5).length,
                      itemBuilder: (context, index) {
                        final concept = concepts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.auto_stories,
                                  color: theme.colorScheme.primary),
                            ),
                            title: Text(concept.title,
                                style: theme.textTheme.titleMedium),
                            subtitle: Text(
                              concept.summary ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: FilledButton(
                              child: const Text('Review'),
                              onPressed: () =>
                                  context.go('/concept/${concept.slug}'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/explore'),
                  icon: const Icon(Icons.explore),
                  label: const Text('Explore New Concepts'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewStat extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String value;
  final String label;

  const _ReviewStat({
    required this.theme,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: theme.textTheme.titleLarge
                ?.copyWith(color: theme.colorScheme.primary)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyReview extends StatelessWidget {
  final ThemeData theme;
  const _EmptyReview({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.replay,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No reviews due', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Start learning concepts to build your review queue',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
