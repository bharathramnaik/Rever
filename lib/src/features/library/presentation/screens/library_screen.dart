import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/providers/library_providers.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedAsync = ref.watch(savedObjectsProvider('mock-profile-id'));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Library', style: theme.textTheme.displayLarge),
              const SizedBox(height: 24),
              savedAsync.when(
                data: (objects) => Expanded(
                  child: objects.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bookmark_border,
                                  size: 64,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text(
                                'Start learning to build your library',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: objects.length,
                          itemBuilder: (context, index) {
                            final obj = objects[index];
                            return Card(
                              child: ListTile(
                                leading: Icon(_iconForType(obj.objectType)),
                                title: Text(obj.title),
                                subtitle: Text(obj.objectType),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {},
                              ),
                            );
                          },
                        ),
                ),
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'card' => Icons.auto_stories,
      'quiz' => Icons.quiz,
      'article' => Icons.article,
      'diagram' => Icons.bubble_chart,
      _ => Icons.menu_book,
    };
  }
}
