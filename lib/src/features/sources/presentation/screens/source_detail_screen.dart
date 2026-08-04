import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/core/services/llm_service.dart';
import 'package:rever/src/core/services/url_text_fetcher.dart';
import 'package:rever/src/data/models/concept_model.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:rever/src/data/models/source_model.dart';
import 'package:rever/src/data/providers/book_access_providers.dart';
import 'package:rever/src/data/providers/idea_card_providers.dart';
import 'package:rever/src/data/providers/idea_relationship_providers.dart';
import 'package:rever/src/data/repositories/book_access_repository.dart';

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

class _SourceDetail extends ConsumerStatefulWidget {
  final SourceModel source;
  final ThemeData theme;

  const _SourceDetail({required this.source, required this.theme});

  @override
  ConsumerState<_SourceDetail> createState() => _SourceDetailState();
}

class _SourceDetailState extends ConsumerState<_SourceDetail> {
  final _urlFetcher = UrlTextFetcher();
  bool _extracting = false;
  bool _extractFailed = false;
  bool _saving = false;
  List<IdeaCard> _ideas = [];

  SourceModel get source => widget.source;

  Future<void> _requestAccess() async {
    final profileId = ref.read(activeProfileIdProvider);
    if (profileId == null) {
      _toast('Select a profile first');
      return;
    }
    try {
      await ref
          .read(bookAccessRepositoryProvider)
          .request(profileId, source.id);
      ref.invalidate(bookAccessGateProvider(profileId));
      if (!mounted) return;
      _toast(
        AppEnvironment.isDev
            ? 'Access granted (dev mode)'
            : 'Request sent — waiting for approval',
      );
    } catch (e) {
      debugPrint('[book] request failed: $e');
      if (mounted) _toast('Could not request access');
    }
  }

  /// One-shot extraction: overall picture + micro-learning structure of the
  /// book. No chat, no follow-up calls — results are static and saveable.
  Future<void> _startMicroLearning() async {
    final configured = ref
        .watch(llmProviderChainProvider)
        .any((c) => c.isConfigured);
    if (!configured) {
      _toast('AI extraction will be available soon');
      return;
    }
    if (source.url == null) {
      _toast('This book has no extractable content yet');
      return;
    }

    setState(() {
      _extracting = true;
      _extractFailed = false;
      _ideas = [];
    });
    try {
      final fetched = await _urlFetcher.fetch(source.url!);
      if (fetched == null || fetched.text.trim().isEmpty) {
        throw Exception('unreachable source');
      }
      final generator = ref.read(contentGeneratorProvider);
      final ideas = await generator.generate(
        fetched.text,
        sourceTitle: source.title,
      );
      if (!mounted) return;
      setState(() => _ideas = ideas);
      if (ideas.isEmpty) _extractFailed = true;
    } catch (e) {
      debugPrint('[book] extraction failed: $e');
      if (mounted) setState(() => _extractFailed = true);
    } finally {
      if (mounted) setState(() => _extracting = false);
    }
  }

  Future<void> _saveToLibrary() async {
    final profileId = ref.read(activeProfileIdProvider);
    if (profileId == null || _ideas.isEmpty) return;
    setState(() => _saving = true);
    try {
      if (AppEnvironment.isDev) {
        final store = await ref.read(localIdeaStoreProvider.future);
        for (final card in _ideas) {
          await store.save(card);
        }
      } else {
        final inserted = await ref
            .read(ideaCardRepositoryProvider)
            .saveGenerated(profileId, _ideas);
        _generateGraphEdges(inserted);
      }
      ref.invalidate(localIdeaCardsProvider);
      if (!mounted) return;
      _toast('Saved to Library');
    } catch (e) {
      debugPrint('[book] save failed: $e');
      if (mounted) _toast('Could not save — try again');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Fire-and-forget knowledge-graph edge curation (non-fatal on failure).
  Future<void> _generateGraphEdges(List<IdeaCard> inserted) async {
    try {
      final repo = ref.read(ideaCardRepositoryProvider);
      final generator = ref.read(relationshipGeneratorProvider);
      for (final card in inserted) {
        final candidates = await repo.fetchFeed(limit: 15);
        if (candidates.isEmpty) return;
        final texts = [
          for (final c in candidates)
            (c.takeaway + ': ' + c.body).replaceAll('\n', ' ').trim(),
        ];
        final edges = await generator.generate(card.body, texts);
        if (edges.isNotEmpty) {
          await ref.read(ideaRelationshipRepositoryProvider).insertGenerated(
            card.id,
            edges,
            [for (final c in candidates) c.id],
          );
        }
      }
    } catch (e) {
      debugPrint('[graph] edge generation skipped (non-fatal): $e');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileId = ref.watch(activeProfileIdProvider);
    final gateAsync = profileId == null
        ? null
        : ref.watch(bookAccessGateProvider(profileId));
    final conceptsAsync = ref.watch(conceptsBySourceProvider(source.id));
    final theme = widget.theme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
        const SizedBox(height: 16),

        _AccessCard(
          gateAsync: gateAsync,
          sourceId: source.id,
          canRequestMore: gateAsync?.asData?.value.canRequestMore ?? true,
          activeCount: gateAsync?.asData?.value.activeCount ?? 0,
          onRequest: _requestAccess,
          onLearn: _extracting ? null : _startMicroLearning,
        ),
        const SizedBox(height: 24),

        if (_ideas.isNotEmpty || _extracting || _extractFailed) ...[
          _ExtractionSection(
            ideas: _ideas,
            extracting: _extracting,
            failed: _extractFailed,
            saving: _saving,
            onRetry: _startMicroLearning,
            onSave: _saveToLibrary,
          ),
          const SizedBox(height: 24),
        ],

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

/// Book access gate: request / status / one-shot micro-learning entry.
class _AccessCard extends StatelessWidget {
  final AsyncValue<BookAccessGate>? gateAsync;
  final String sourceId;
  final bool canRequestMore;
  final int activeCount;
  final VoidCallback onRequest;
  final VoidCallback? onLearn;

  const _AccessCard({
    required this.gateAsync,
    required this.sourceId,
    required this.canRequestMore,
    required this.activeCount,
    required this.onRequest,
    required this.onLearn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gate = gateAsync?.asData?.value;
    final status = gate?.statusFor(sourceId)?.status;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_open, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Micro-learning access',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${3 - activeCount} of 3 access slots remaining',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            switch (status) {
              'granted' => SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onLearn,
                    icon: onLearn == null
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: const Text(
                      'Start Micro-learning (AI extract)',
                    ),
                  ),
                ),
              'requested' => const _AccessNotice(
                icon: Icons.hourglass_top,
                text: 'Requested — waiting for approval',
              ),
              'denied' => const _AccessNotice(
                icon: Icons.block,
                text: 'Access denied by the owner',
              ),
              _ => SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: canRequestMore ? onRequest : null,
                    icon: const Icon(Icons.request_page),
                    label: Text(
                      canRequestMore
                          ? 'Request access'
                          : 'Access limit reached (3 books)',
                    ),
                  ),
                ),
            },
          ],
        ),
      ),
    );
  }
}

class _AccessNotice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AccessNotice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

/// Results of the one-shot book extraction (overall picture + structure).
class _ExtractionSection extends StatelessWidget {
  final List<IdeaCard> ideas;
  final bool extracting;
  final bool failed;
  final bool saving;
  final VoidCallback onRetry;
  final VoidCallback onSave;

  const _ExtractionSection({
    required this.ideas,
    required this.extracting,
    required this.failed,
    required this.saving,
    required this.onRetry,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (extracting) {
      return Column(
        children: [
          Text(
            'Extracting the overall picture and micro-learning structure...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }
    if (failed) {
      return Column(
        children: [
          Text(
            'Could not extract this book yet — the AI service was not '
            'reachable. Try again shortly.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Micro-learning cards',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          '${ideas.length} ideas extracted from this book',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 12),
        ...ideas.map(
          (i) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          i.takeaway,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(i.body, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_added),
            label: Text(saving ? 'Saving...' : 'Save to Library'),
          ),
        ),
      ],
    );
  }
}
