import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/data/models/topic_model.dart';
import 'package:rever/src/data/providers/topic_providers.dart';
import 'package:rever/src/data/providers/source_providers.dart';
import 'package:rever/src/data/providers/search_provider.dart';

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
    'nature_people' || 'forest' => Icons.nature,
    'engineering' || 'precision_manufacturing' => Icons.build,
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

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topicsAsync = ref.watch(topicsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What do you want to learn?',
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                // Functional search field
                TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).update(value);
                    setState(() => _isSearching = value.trim().isNotEmpty);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search topics, concepts, sources...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).clear();
                              setState(() => _isSearching = false);
                              _focusNode.unfocus();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Show search results or browse content
                if (_isSearching && searchQuery.trim().isNotEmpty)
                  _SearchResultsView()
                else ...[
                  Text('Topics', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  topicsAsync.when(
                    data: (topics) => GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                    loading: () => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Center(child: Text('$e')),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Books', style: theme.textTheme.headlineMedium),
                      TextButton(
                        onPressed: () => context.go('/sources'),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Up to 10 books shown. Access is limited to 3 books '
                      'per profile.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _BooksPreview(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Live search results displayed below the search field
class _SearchResultsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text('No results found',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      )),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${results.totalCount} results',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),

            // Topics
            if (results.topics.isNotEmpty) ...[
              Text('Topics', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...results.topics.map((t) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(_iconFromName(t.icon),
                          color: _colorFromString(t.color)),
                      title: Text(t.name),
                      subtitle:
                          t.description != null ? Text(t.description!) : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/topic/${t.slug}'),
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Concepts
            if (results.concepts.isNotEmpty) ...[
              Text('Concepts', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...results.concepts.map((c) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.auto_stories,
                          color: theme.colorScheme.primary),
                      title: Text(c.title),
                      subtitle: c.summary != null
                          ? Text(c.summary!,
                              maxLines: 1, overflow: TextOverflow.ellipsis)
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text(c.difficulty,
                                style: const TextStyle(fontSize: 10)),
                            visualDensity: VisualDensity.compact,
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () => context.go('/concept/${c.slug}'),
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Sources
            if (results.sources.isNotEmpty) ...[
              Text('Sources', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...results.sources.map((s) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.menu_book,
                          color: theme.colorScheme.secondary),
                      title: Text(s.title),
                      subtitle: Text(s.sourceType ?? 'Source'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  )),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Center(child: Text('Search error: $e')),
    );
  }
}

/// Top 10 books (sources) by preference-fit; tap through to the book detail
/// where access can be requested (capped at 3 per profile).
class _BooksPreview extends ConsumerWidget {
  const _BooksPreview();

  static const _maxBooks = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sourcesAsync = ref.watch(sourcesProvider);

    return sourcesAsync.when(
      data: (sources) {
        final books = sources.take(_maxBooks).toList();
        if (books.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Books will appear here once published and approved.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          );
        }
        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final s = books[index];
              return GestureDetector(
                onTap: () => context.go('/source/${s.id}'),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.menu_book, color: theme.colorScheme.primary),
                      const Spacer(),
                      Text(
                        s.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 110),
      error: (_, __) => const SizedBox(height: 110),
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
