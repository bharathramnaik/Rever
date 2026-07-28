import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/data/models/topic_model.dart';
import 'package:rever/src/data/providers/topic_providers.dart';

IconData _iconFromName(String? name) {
  return switch (name) {
    'code' => Icons.code,
    'biotech' => Icons.biotech,
    'calculate' => Icons.calculate,
    'history' => Icons.history,
    'psychology' => Icons.psychology,
    'account_balance' => Icons.account_balance,
    'self_improvement' => Icons.self_improvement,
    'rocket_launch' => Icons.rocket_launch,
    'palette' => Icons.palette,
    'favorite' => Icons.favorite,
    'nature_people' => Icons.nature,
    'engineering' => Icons.build,
    _ => Icons.explore,
  };
}

Color _colorFromString(String? color) {
  if (color == null) return const Color(0xFF6C63FF);
  final hex = color.replaceFirst('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  }
  return const Color(0xFF6C63FF);
}

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final topicsAsync = ref.watch(topicsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What do you want to learn?',
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search any topic...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Topics', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Expanded(
                child: topicsAsync.when(
                  data: (topics) => GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return _TopicCard(topic: topic);
                    },
                  ),
                  loading: () => const Center(
                      child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends ConsumerWidget {
  final TopicModel topic;
  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final icon = _iconFromName(topic.icon);
    final color = _colorFromString(topic.color);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/topic/${topic.slug}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                topic.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
