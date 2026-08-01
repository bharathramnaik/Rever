import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/models/explore_content_model.dart';
import 'package:rever/src/data/models/preferences_model.dart';
import 'package:rever/src/data/providers/library_providers.dart';
import 'package:rever/src/data/providers/preferences_provider.dart';
import 'package:rever/src/data/services/external_content_service.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileId = ref.watch(activeProfileIdProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('Library', style: theme.textTheme.displayLarge),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.5),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.explore), text: 'Discover'),
                Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
                Tab(icon: Icon(Icons.auto_stories), text: 'Concepts'),
              ],
            ),
            Expanded(
              child: profileId == null
                  ? _NoProfile(theme: theme)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        const _DiscoverTab(),
                        _SavedTab(profileId: profileId),
                        _ConceptsTab(profileId: profileId),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoProfile extends StatelessWidget {
  final ThemeData theme;
  const _NoProfile({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('Select a profile to see your library',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              )),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go('/profiles'),
            child: const Text('Switch Profile'),
          ),
        ],
      ),
    );
  }
}

class _DiscoverTab extends ConsumerStatefulWidget {
  const _DiscoverTab();

  @override
  ConsumerState<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<_DiscoverTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendingAsync = ref.watch(trendingContentProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
        if (_searchQuery.isNotEmpty)
          _SearchResults(query: _searchQuery)
        else
          trendingAsync.when(
            data: (items) {
              final prefs = ref.watch(activePreferencesProvider).asData?.value;
              final topics = prefs?.topics ?? const [];
              final personalized = topics.isNotEmpty;

              final books =
                  items.where((i) => i.source == ContentSource.book).toList();
              final articles =
                  items.where((i) => i.source == ContentSource.article).toList();
              final matchedBooks =
                  books.where((b) => matchesPreferences(b, topics)).toList();
              final shownBooks = matchedBooks.isNotEmpty ? matchedBooks : books;
              final booksSectionLabel =
                  personalized ? 'Picked for you' : 'Trending Books';
              return SliverList(
                delegate: SliverChildListDelegate([
                  if (shownBooks.isNotEmpty) ...[
                    _SectionHeader(label: booksSectionLabel, theme: theme),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: shownBooks.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _BookCard(
                          item: shownBooks[i],
                          onTap: () =>
                              _openReel(context, shownBooks, index: i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                  if (articles.isNotEmpty) ...[
                    _SectionHeader(label: 'Discover Articles', theme: theme),
                    const SizedBox(height: 12),
                    ...articles.map(
                      (a) => _ArticleCard(
                        item: a,
                        onTap: () => _openReel(context, articles, index: articles.indexOf(a)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ]),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_off, size: 48,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('Could not load content',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resultsAsync = ref.watch(searchBooksProvider(query));

    return resultsAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No books found for "$query"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    )),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: i == 0 ? 0 : 8, bottom: 8,
              ),
              child: _BookRow(
                item: books[i],
                onTap: () => _openReel(context, books, index: i),
              ),
            ),
            childCount: books.length,
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(child: Text('$e')),
      ),
    );
  }
}

void _openReel(BuildContext context, List<ExploreContent> items,
    {int index = 0}) {
  context.push('/content-reel', extra: {'items': items, 'index': index});
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _SectionHeader({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final ExploreContent item;
  final VoidCallback? onTap;
  const _BookCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 170,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.thumbnailUrl != null)
                      Image.network(
                        item.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _coverFallback(theme),
                      )
                    else
                      _coverFallback(theme),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'BOOK',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  if (item.author != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.author!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverFallback(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book,
              size: 40, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  final ExploreContent item;
  final VoidCallback? onTap;
  const _BookRow({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item.thumbnailUrl != null
              ? Image.network(
                  item.thumbnailUrl!,
                  width: 44, height: 64, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 44, height: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    child: Icon(Icons.menu_book, size: 24,
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.3)),
                  ),
                )
              : Container(
                  width: 44, height: 64,
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                  child: Icon(Icons.menu_book, size: 24,
                      color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                ),
        ),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: item.author != null
            ? Text(item.author!, style: theme.textTheme.bodySmall)
            : null,
        trailing: Icon(Icons.add_circle_outline,
            color: theme.colorScheme.primary),
        onTap: onTap,
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final ExploreContent item;
  final VoidCallback? onTap;
  const _ArticleCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.article,
                      color: theme.colorScheme.secondary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ARTICLE',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontSize: 9,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(item.title, maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                      if (item.description != null) ...[
                        const SizedBox(height: 4),
                        Text(item.description!, maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedTab extends ConsumerWidget {
  final String profileId;
  const _SavedTab({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedAsync = ref.watch(savedObjectsProvider(profileId));

    return savedAsync.when(
      data: (objects) {
        if (objects.isEmpty) {
          return _EmptyState(
            theme: theme,
            icon: Icons.bookmark_border,
            title: 'Nothing saved yet',
            subtitle: 'Tap the bookmark icon on any concept to save it here',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: objects.length,
          itemBuilder: (context, index) {
            final obj = objects[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  child:
                      Icon(_iconForType(obj.objectType), color: theme.colorScheme.primary),
                ),
                title: Text(obj.title),
                subtitle: Row(
                  children: [
                    Text(
                      obj.objectType[0].toUpperCase() + obj.objectType.substring(1),
                      style: theme.textTheme.bodySmall,
                    ),
                    if (obj.estimatedDuration != null) ...[
                      const SizedBox(width: 8),
                      Text('${(obj.estimatedDuration! / 60).ceil()} min',
                          style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go('/concept/${obj.conceptId}');
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'card' => Icons.auto_stories,
      'quiz' => Icons.quiz,
      'article' => Icons.article,
      'diagram' => Icons.bubble_chart,
      'flashcard' => Icons.flip,
      'exercise' => Icons.fitness_center,
      _ => Icons.menu_book,
    };
  }
}

class _ConceptsTab extends ConsumerWidget {
  final String profileId;
  const _ConceptsTab({required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return _EmptyState(
      theme: theme,
      icon: Icons.auto_stories,
      title: 'Concepts you\'ve studied',
      subtitle: 'Concepts will appear here as you learn and quiz',
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
