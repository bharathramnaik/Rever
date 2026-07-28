import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/providers/concept_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _GreetingHeader(),
                const SizedBox(height: 24),
                const _DailyJourney(),
                const SizedBox(height: 32),
                Text(
                  'Explore Concepts',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const _ExploreConcepts(),
                const SizedBox(height: 32),
                Text(
                  'Your Knowledge',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const _KnowledgeOverview(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';
    final profile = ref.watch(activeProfileIdProvider);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text(profile ?? 'Learner',
                  style: theme.textTheme.displayLarge),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/profiles'),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              (profile ?? 'L')[0],
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyJourney extends ConsumerWidget {
  const _DailyJourney();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your 10-minute Journey',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const _JourneyItem(
            icon: Icons.auto_stories,
            text: 'Learn: How transformers work',
            duration: '2 min',
          ),
          const _JourneyItem(
            icon: Icons.explore,
            text: 'Explore: Transformer visual map',
            duration: '3 min',
          ),
          const _JourneyItem(
            icon: Icons.quiz,
            text: 'Quiz: Test yesterday\'s concepts',
            duration: '2 min',
          ),
          const _JourneyItem(
            icon: Icons.replay,
            text: 'Remember: 3 concepts due',
            duration: '2 min',
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.3,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _JourneyItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String duration;

  const _JourneyItem({
    required this.icon,
    required this.text,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text, style: const TextStyle(color: Colors.white))),
          Text(
            duration,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _ExploreConcepts extends ConsumerWidget {
  const _ExploreConcepts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final conceptsAsync = ref.watch(allConceptsProvider);

    return conceptsAsync.when(
      data: (concepts) {
        if (concepts.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('No concepts available')),
          );
        }
        final display = concepts.take(6).toList();
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: display.length,
            itemBuilder: (context, index) {
              final concept = display[index];
              return GestureDetector(
                onTap: () => context.go('/concept/${concept.slug}'),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(Icons.auto_stories,
                              color: theme.colorScheme.primary),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        concept.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: 0.3 + (index * 0.1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        concept.difficulty,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: 100,
        child: Center(child: Text('$e')),
      ),
    );
  }
}

class _KnowledgeOverview extends StatelessWidget {
  const _KnowledgeOverview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          _KnowledgeStat(theme, '82%', 'Technology'),
          _Divider(theme),
          _KnowledgeStat(theme, '76%', 'AI'),
          _Divider(theme),
          _KnowledgeStat(theme, '69%', 'Finance'),
        ],
      ),
    );
  }
}

class _KnowledgeStat extends StatelessWidget {
  final ThemeData theme;
  final String value;
  final String label;

  const _KnowledgeStat(this.theme, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
              )),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final ThemeData theme;
  const _Divider(this.theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: theme.colorScheme.outline,
    );
  }
}
