import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/providers/feed_provider.dart';
import 'package:rever/src/data/models/feed_item_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const _FeedHeader(),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const _FeedContent(),
          ],
        ),
      ),
    );
  }
}

class _FeedHeader extends ConsumerWidget {
  const _FeedHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening';
    final profile = ref.watch(activeProfileIdProvider);

    return SliverAppBar(
      floating: true,
      backgroundColor: theme.colorScheme.surface,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: theme.textTheme.bodySmall),
          Text(profile ?? 'Learner', style: theme.textTheme.titleLarge),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => context.go('/profiles'),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                (profile ?? 'L')[0].toUpperCase(),
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedContent extends ConsumerWidget {
  const _FeedContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);

    return feedAsync.when(
      data: (items) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return _FeedCard(item: item);
          },
          childCount: items.length,
        ),
      ),
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('$e')),
      ),
    );
  }
}

class _FeedCard extends ConsumerWidget {
  final FeedItemModel item;

  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    switch (item.type) {
      case FeedItemType.discovery:
        return _DiscoveryCard(item: item, theme: theme);
      case FeedItemType.insight:
        return _InsightCard(item: item, theme: theme);
      case FeedItemType.concept:
        return _ConceptFeedCard(item: item, theme: theme);
      case FeedItemType.question:
        return _QuestionCard(item: item, theme: theme);
      case FeedItemType.challenge:
        return _ChallengeCard(item: item, theme: theme);
      default:
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(title: Text(item.title)),
        );
    }
  }
}

class _DiscoveryCard extends StatelessWidget {
  final FeedItemModel item;
  final ThemeData theme;

  const _DiscoveryCard({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text('Today', style: TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.title, style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text(item.subtitle ?? '', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: 0.3, backgroundColor: Colors.white30, color: Colors.white),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final FeedItemModel item;
  final ThemeData theme;

  const _InsightCard({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    final colorHex = item.metadata?['color'] as String? ?? '#6C63FF';
    final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.explore, color: color),
        ),
        title: Text(item.title, style: theme.textTheme.titleMedium),
        subtitle: Text(item.subtitle ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          final slug = item.metadata?['slug'] as String?;
          if (slug != null) context.go('/topic/$slug');
        },
      ),
    );
  }
}

class _ConceptFeedCard extends StatelessWidget {
  final FeedItemModel item;
  final ThemeData theme;

  const _ConceptFeedCard({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.auto_stories, color: theme.colorScheme.primary),
        ),
        title: Text(item.title, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.subtitle != null)
              Text(item.subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(item.metadata?['difficulty'] as String? ?? 'beginner', style: const TextStyle(fontSize: 10)),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                if (item.metadata?['minutes'] != null)
                  Text('${item.metadata!['minutes']} min', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          final slug = item.metadata?['slug'] as String?;
          if (slug != null) context.go('/concept/$slug');
        },
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final FeedItemModel item;
  final ThemeData theme;

  const _QuestionCard({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: theme.colorScheme.primary.withValues(alpha: 0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.help_outline, color: theme.colorScheme.secondary),
        ),
        title: Text(item.title, style: theme.textTheme.titleMedium),
        subtitle: Text(item.subtitle ?? ''),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          final slug = item.metadata?['concept_slug'] as String?;
          if (slug != null) context.go('/concept/$slug');
        },
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final FeedItemModel item;
  final ThemeData theme;

  const _ChallengeCard({required this.item, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: theme.textTheme.titleMedium),
                Text(item.subtitle ?? '', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}
