import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                  'Continue Learning',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const _ContinueLearning(),
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
    final greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text('Bharath', style: theme.textTheme.displayLarge),
            ],
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primary,
          child: Text('B', style: TextStyle(color: theme.colorScheme.onPrimary)),
        ),
      ],
    );
  }
}

class _DailyJourney extends StatelessWidget {
  const _DailyJourney();

  @override
  Widget build(BuildContext context) {
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
          _JourneyItem(
            icon: Icons.auto_stories,
            text: 'Learn: How transformers work',
            duration: '2 min',
          ),
          _JourneyItem(
            icon: Icons.explore,
            text: 'Explore: Transformer visual map',
            duration: '3 min',
          ),
          _JourneyItem(
            icon: Icons.quiz,
            text: 'Quiz: Test yesterday\'s concepts',
            duration: '2 min',
          ),
          _JourneyItem(
            icon: Icons.replay,
            text: 'Remember: 3 concepts due',
            duration: '2 min',
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: 0.3,
            backgroundColor: Colors.white.withOpacity(0.3),
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
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white))),
          Text(
            duration,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearning extends StatelessWidget {
  const _ContinueLearning();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
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
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Text(
                  'Understanding AI',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: 0.68),
              ],
            ),
          );
        },
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
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(
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
