import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/core/services/duplicate_detector.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/models/explore_content_model.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:rever/src/data/models/stash_card_model.dart';
import 'package:rever/src/data/providers/idea_card_providers.dart';
import 'package:rever/src/data/providers/idea_relationship_providers.dart';
import 'package:rever/src/data/services/external_content_service.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _urlController = TextEditingController();
  final _noteController = TextEditingController();
  final _youtubeController = TextEditingController();
  bool _processing = false;
  bool _processingFailed = false;
  List<StashCard> _generatedCards = [];
  List<IdeaCard> _generatedIdeas = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text('Create', style: theme.textTheme.displayLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                'Import sources and generate idea cards',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.5),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.link), text: 'URL'),
                Tab(icon: Icon(Icons.edit_note), text: 'Note'),
                Tab(icon: Icon(Icons.videocam_outlined), text: 'YouTube'),
              ],
            ),
            Expanded(
              child: _processing
                  ? _ProcessingView()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _UrlTab(
                          controller: _urlController,
                          onProcess: _processSource,
                        ),
                        _NoteTab(
                          controller: _noteController,
                          onProcess: _processSource,
                        ),
                        _YoutubeTab(
                          controller: _youtubeController,
                          onProcess: _processSource,
                        ),
                      ],
                    ),
            ),
            if (_generatedCards.isNotEmpty)
              _ReviewBar(
                count: _generatedCards.length,
                onView: () => _showReviewSheet(),
                onClear: () => setState(() => _generatedCards = []),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _processSource(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _processing = true;
      _processingFailed = false;
      _generatedCards = [];
      _generatedIdeas = [];
    });

    final generator = ref.read(contentGeneratorProvider);
    try {
      final ideas = await generator.generate(text);
      setState(() {
        _generatedIdeas = ideas;
        _generatedCards = ideas
            .map((i) => StashCard(
                title: i.takeaway, content: i.body, type: StashType.idea))
            .toList();
      });
    } on Exception catch (e, st) {
      debugPrint('[create] LLM generation failed: $e\n$st');
      // Fallback: heuristic generation so the UI always shows something.
      final service = ref.read(externalContentServiceProvider);
      final item = ExploreContent(
        id: 'generated',
        title: text.length > 60 ? '${text.substring(0, 60)}...' : text,
        description: text,
        source: ContentSource.article,
      );
      final stashes = service.generateStashes(item);
      setState(() {
        _generatedCards = stashes;
        _processingFailed = true;
      });
    }
    setState(() => _processing = false);
  }

  Future<void> _saveToLibrary() async {
    if (_generatedIdeas.isEmpty) {
      // Fallback cards (heuristic) synthesize IdeaCards.
      _generatedIdeas = _generatedCards
          .map((c) => IdeaCard(
              id: '${DateTime.now().millisecondsSinceEpoch}',
              takeaway: c.title,
              body: c.content))
          .toList();
    }
    if (_generatedIdeas.isEmpty) return;
    final profileId = ref.read(activeProfileIdProvider);
    if (profileId == null) return;

    // Sprint 5 (flow.txt §7): duplicate detection + quality gate before save.
    final kept = await _dedupeGenerated();
    if (kept.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All ideas already exist in your library')),
      );
      return;
    }
    _generatedIdeas = kept;

    // Dev mode: demo profile ids (e.g. `dev-bharath`) are not real UUIDs, so
    // profile-scoped Supabase writes throw `invalid input syntax for type uuid`
    // (22P02). Persist to the device cache only (dev bypasses Supabase).
    if (AppEnvironment.isDev) {
      final store = await ref.read(localIdeaStoreProvider.future);
      for (final card in _generatedIdeas) {
        await store.save(card);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to Library')),
      );
      return;
    }

    try {
      final inserted = await ref
          .read(ideaCardRepositoryProvider)
          .saveGenerated(profileId, _generatedIdeas);
      _generateGraphEdges(inserted);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to Library')),
      );
    } catch (e, st) {
      debugPrint('[create] save to Supabase failed, using device cache: $e\n$st');
      final store = await ref.read(localIdeaStoreProvider.future);
      for (final card in _generatedIdeas) {
        await store.save(card);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Saved to this device (syncs when online)')),
      );
    }
    if (!mounted) return;
    setState(() {
      _generatedCards = [];
      _generatedIdeas = [];
    });
    ref.invalidate(localIdeaCardsProvider);
  }

  /// Fire-and-forget AI curation of knowledge-graph edges for newly created
  /// cards (flow.txt §5). Non-fatal: failures never block the save flow.
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
          await ref
              .read(ideaRelationshipRepositoryProvider)
              .insertGenerated(
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

  /// Filters generated ideas against existing cards (flow.txt §7): near-dupes
  /// are dropped, surviving cards are re-scored by the structural quality gate.
  Future<List<IdeaCard>> _dedupeGenerated() async {
    try {
      final List<String> existingTexts;
      if (AppEnvironment.isDev) {
        final store = await ref.read(localIdeaStoreProvider.future);
        existingTexts = [
          for (final c in await store.loadAll()) '${c.takeaway} ${c.body}',
        ];
      } else {
        existingTexts = [
          for (final c in await ref.read(ideaCardRepositoryProvider).fetchFeed(limit: 100))
            '${c.takeaway} ${c.body}',
        ];
      }
      const detector = DuplicateDetector();
      final kept = <IdeaCard>[];
      for (final card in _generatedIdeas) {
        if (detector.isDuplicate('${card.takeaway} ${card.body}', existingTexts)) {
          continue;
        }
        if (card.qualityScore <= 0) {
          kept.add(IdeaCard(
            id: card.id,
            sourceId: card.sourceId,
            conceptId: card.conceptId,
            takeaway: card.takeaway,
            body: card.body,
            qualityScore: card.takeaways.isNotEmpty ? 0.6 : 0.3,
            tags: card.tags,
          ));
        } else {
          kept.add(card);
        }
      }
      return kept;
    } catch (e) {
      debugPrint('[create] dedupe skipped (non-fatal): $e');
      return _generatedIdeas;
    }
  }

  void _showReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Generated Ideas',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${_generatedCards.length} cards extracted',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      )),
              if (_processingFailed) ...[
                const SizedBox(height: 8),
                Text('Showing heuristic fallbacks. Connect an LLM key for AI.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                        )),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: _generatedCards.length,
                  itemBuilder: (_, i) {
                    final card = _generatedCards[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  card.type == StashType.overview
                                      ? Icons.info_outline
                                      : Icons.lightbulb_outline,
                                  size: 18,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  card.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card.content,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _saveToLibrary(),
                  icon: const Icon(Icons.bookmark_added),
                  label: const Text('Save to Library'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessingView extends StatefulWidget {
  @override
  State<_ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<_ProcessingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  int _step = 0;

  final _steps = [
    'Parsing source content...',
    'Extracting key ideas...',
    'Generating insight cards...',
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _advance();
  }

  void _advance() async {
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _step = i);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _anim,
              builder: (_, child) => Transform.rotate(
                angle: _anim.value * 6.28,
                child: Icon(Icons.auto_stories,
                    size: 56,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _steps[_step],
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _steps.length,
                  minHeight: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UrlTab extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onProcess;

  const _UrlTab({required this.controller, required this.onProcess});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.link, size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('Paste a web article URL',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('AI will extract key ideas from the page',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              )),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'https://example.com/article',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => onProcess(controller.text),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Extract Ideas'),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteTab extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onProcess;

  const _NoteTab({required this.controller, required this.onProcess});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.edit_note, size: 48,
              color: theme.colorScheme.secondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('Write a raw note or paste text',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Paste book excerpts, articles, or your thoughts',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              )),
          const SizedBox(height: 20),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Paste your content here...',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => onProcess(controller.text),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Extract Ideas'),
            ),
          ),
        ],
      ),
    );
  }
}

class _YoutubeTab extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onProcess;

  const _YoutubeTab({required this.controller, required this.onProcess});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.videocam_outlined, size: 48,
              color: Colors.red.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('Paste a YouTube video link',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Get key takeaways from video content',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              )),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'https://youtube.com/watch?v=...',
              prefixIcon: const Icon(Icons.play_circle_outline),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => onProcess(controller.text),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Extract Ideas'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewBar extends StatelessWidget {
  final int count;
  final VoidCallback onView;
  final VoidCallback onClear;

  const _ReviewBar({
    required this.count,
    required this.onView,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle,
              color: Colors.green.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: 8),
          Text('$count ideas generated',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              )),
          const Spacer(),
          TextButton(
            onPressed: onClear,
            child: const Text('Clear'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onView,
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }
}
