import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/source_model.dart';
import 'package:rever/src/data/models/concept_model.dart';

/// Fetch a source by ID
final sourceByIdProvider =
    FutureProvider.family<SourceModel?, String>((ref, id) async {
  final client = ref.watch(supabaseProvider);
  final data =
      await client.from('sources').select().eq('id', id).maybeSingle();
  if (data == null) return null;
  return SourceModel.fromJson(data);
});

/// Fetch concepts linked to a source (via learning_objects → concept_id)
final conceptsBySourceProvider =
    FutureProvider.family<List<ConceptModel>, String>((ref, sourceId) async {
  final client = ref.watch(supabaseProvider);
  // Get unique concept_ids from learning objects with this source
  final loData = await client
      .from('learning_objects')
      .select('concept_id')
      .eq('source_id', sourceId);
  final conceptIds = (loData as List)
      .map((e) => e['concept_id'] as String)
      .toSet()
      .toList();
  if (conceptIds.isEmpty) return [];

  final conceptData = await client
      .from('concepts')
      .select()
      .inFilter('id', conceptIds);
  return (conceptData as List)
      .map((e) => ConceptModel.fromJson(e))
      .toList();
});

class SourceDetailScreen extends ConsumerWidget {
  final String sourceId;
  const SourceDetailScreen({super.key, required this.sourceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sourceAsync = ref.watch(sourceByIdProvider(sourceId));

    return Scaffold(
      appBar: AppBar(
        title: sourceAsync.when(
          data: (s) => Text(s?.title ?? 'Source'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
      ),
      body: sourceAsync.when(
        data: (source) {
          if (source == null) {
            return const Center(child: Text('Source not found'));
          }
          return _SourceDetail(source: source, theme: theme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _SourceDetail extends ConsumerWidget {
  final SourceModel source;
  final ThemeData theme;

  const _SourceDetail({required this.source, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptsAsync = ref.watch(conceptsBySourceProvider(source.id));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Source info card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.08),
                theme.colorScheme.secondary.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book,
                      color: theme.colorScheme.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(source.title,
                        style: theme.textTheme.headlineMedium),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (source.sourceType != null)
                    Chip(
                      label: Text(source.sourceType!),
                      visualDensity: VisualDensity.compact,
                    ),
                  const SizedBox(width: 8),
                  if (source.license != null)
                    Chip(
                      avatar: const Icon(Icons.copyright, size: 14),
                      label: Text(source.license!),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              if (source.url != null) ...[
                const SizedBox(height: 12),
                Text(
                  source.url!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Concepts from this source
        conceptsAsync.when(
          data: (concepts) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Concepts', style: theme.textTheme.headlineMedium),
                    const Spacer(),
                    Text('${concepts.length} concepts',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 12),
                if (concepts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No concepts extracted from this source yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                else ...[
                  ...concepts.map((c) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(Icons.auto_stories,
                              color: theme.colorScheme.primary),
                          title: Text(c.title),
                          subtitle: c.summary != null
                              ? Text(c.summary!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)
                              : null,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go('/concept/${c.slug}'),
                        ),
                      )),
                  const SizedBox(height: 16),
                  if (concepts.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Learning'),
                        onPressed: () =>
                            context.go('/concept/${concepts.first.slug}'),
                      ),
                    ),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading concepts: $e'),
        ),
      ],
    );
  }
}
