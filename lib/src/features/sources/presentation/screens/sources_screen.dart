import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/models/source_model.dart';
import 'package:rever/src/data/providers/source_providers.dart';

class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sourcesAsync = ref.watch(sourcesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sources')),
      body: sourcesAsync.when(
        data: (sources) {
          if (sources.isEmpty) {
            return const Center(child: Text('No sources yet'));
          }
          final grouped = _groupByType(sources);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...entry.value.map((s) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: _typeIcon(s.sourceType, theme),
                          title: Text(s.title),
                          subtitle: Text(s.sourceType ?? 'Unknown',
                              style: theme.textTheme.bodySmall),
                        ),
                      )),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Map<String, List<SourceModel>> _groupByType(List<SourceModel> sources) {
    final map = <String, List<SourceModel>>{};
    for (final s in sources) {
      final type = s.sourceType ?? 'Other';
      map.putIfAbsent(type, () => []).add(s);
    }
    return map;
  }

  Widget _typeIcon(String? type, ThemeData theme) {
    IconData icon;
    switch (type?.toLowerCase()) {
      case 'book':
        icon = Icons.menu_book;
      case 'article':
        icon = Icons.article;
      case 'video':
        icon = Icons.videocam;
      case 'podcast':
        icon = Icons.podcasts;
      case 'research':
        icon = Icons.science;
      case 'course':
        icon = Icons.school;
      default:
        icon = Icons.link;
    }
    return CircleAvatar(
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(icon, color: theme.colorScheme.primary),
    );
  }
}
