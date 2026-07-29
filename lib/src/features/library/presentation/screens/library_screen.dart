import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/providers/library_providers.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
              child: Text('Your Library', style: theme.textTheme.displayLarge),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.5),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
                Tab(icon: Icon(Icons.auto_stories), text: 'Concepts'),
                Tab(icon: Icon(Icons.edit_note), text: 'Notes'),
                Tab(icon: Icon(Icons.history), text: 'History'),
              ],
            ),
            Expanded(
              child: profileId == null
                  ? _NoProfile(theme: theme)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _SavedTab(profileId: profileId),
                        _ConceptsTab(profileId: profileId),
                        _NotesTab(theme: theme),
                        _HistoryTab(theme: theme),
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
    // For now, show mastered concepts — this will use mastery table
    return _EmptyState(
      theme: theme,
      icon: Icons.auto_stories,
      title: 'Concepts you\'ve studied',
      subtitle: 'Concepts will appear here as you learn and quiz',
    );
  }
}

class _NotesTab extends StatelessWidget {
  final ThemeData theme;
  const _NotesTab({required this.theme});

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      theme: theme,
      icon: Icons.edit_note,
      title: 'Your notes',
      subtitle: 'Notes you take while learning will appear here',
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final ThemeData theme;
  const _HistoryTab({required this.theme});

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      theme: theme,
      icon: Icons.history,
      title: 'Learning history',
      subtitle: 'Your learning sessions and activity timeline',
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
