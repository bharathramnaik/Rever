import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/providers/concept_providers.dart';
import 'package:rever/src/data/providers/library_providers.dart';
import 'package:rever/src/data/providers/relationship_providers.dart';
import 'package:rever/src/data/models/concept_model.dart';
import 'package:rever/src/data/models/learning_object_model.dart';

const _depthLevels = [
  (label: 'Glance', icon: Icons.quickreply, level: 1, desc: 'Quick insight'),
  (label: 'Understand', icon: Icons.psychology, level: 2, desc: 'Explanation + example'),
  (label: 'Explore', icon: Icons.explore, level: 3, desc: 'Visual map + relationships'),
  (label: 'Master', icon: Icons.auto_stories, level: 4, desc: 'Lesson + quiz'),
  (label: 'Apply', icon: Icons.build, level: 5, desc: 'Exercise + project'),
];

class ConceptScreen extends ConsumerStatefulWidget {
  final String conceptId;
  const ConceptScreen({super.key, required this.conceptId});

  @override
  ConsumerState<ConceptScreen> createState() => _ConceptScreenState();
}

class _ConceptScreenState extends ConsumerState<ConceptScreen> {
  int _selectedDepth = 1;

  @override
  Widget build(BuildContext context) {
    final conceptAsync = ref.watch(conceptBySlugProvider(widget.conceptId));

    return Scaffold(
      appBar: AppBar(
        title: conceptAsync.when(
          data: (c) => Text(c?.title ?? 'Concept'),
          loading: () => const Text('Loading...'),
          error: (e, _) => const Text('Error'),
        ),
        actions: [
          _BookmarkButton(conceptId: widget.conceptId),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: conceptAsync.when(
        data: (concept) {
          if (concept == null) {
            return const Center(child: Text('Concept not found'));
          }
          return _ConceptContent(
            concept: concept,
            selectedDepth: _selectedDepth,
            onDepthChanged: (d) => setState(() => _selectedDepth = d),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

/// Bookmark button that checks saved state and toggles save/unsave
class _BookmarkButton extends ConsumerStatefulWidget {
  final String conceptId;
  const _BookmarkButton({required this.conceptId});

  @override
  ConsumerState<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends ConsumerState<_BookmarkButton> {
  bool _isSaved = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final profileId = ref.watch(activeProfileIdProvider);

    return IconButton(
      icon: Icon(
        _isSaved ? Icons.bookmark : Icons.bookmark_outline,
        color: _isSaved ? Theme.of(context).colorScheme.primary : null,
      ),
      onPressed: _isLoading
          ? null
          : () async {
              if (profileId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select a profile first')),
                );
                return;
              }
              final messenger = ScaffoldMessenger.of(context);
              setState(() => _isLoading = true);
              try {
                final repo = ref.read(libraryRepositoryProvider);
                if (_isSaved) {
                  await repo.unsaveObject(profileId, widget.conceptId);
                  setState(() => _isSaved = false);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Removed from library')),
                    );
                  }
                } else {
                  await repo.saveObject(profileId, widget.conceptId);
                  setState(() => _isSaved = true);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Saved to library')),
                    );
                  }
                }
                // Invalidate library cache
                ref.invalidate(savedObjectsProvider(profileId));
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
    );
  }
}

class _ConceptContent extends ConsumerWidget {
  final ConceptModel concept;
  final int selectedDepth;
  final ValueChanged<int> onDepthChanged;

  const _ConceptContent({
    required this.concept,
    required this.selectedDepth,
    required this.onDepthChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final objectsAsync = ref.watch(learningObjectsProvider(concept.id));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(concept.title, style: theme.textTheme.displayLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Chip(
              label: Text(
                concept.difficulty[0].toUpperCase() +
                    concept.difficulty.substring(1),
              ),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            if (concept.estimatedMinutes != null)
              Text('${concept.estimatedMinutes} min read',
                  style: theme.textTheme.bodyMedium),
          ],
        ),
        if (concept.summary != null) ...[
          const SizedBox(height: 16),
          Text(concept.summary!, style: theme.textTheme.bodyLarge),
        ],
        const SizedBox(height: 24),

        // Action buttons row
        _ConceptActions(concept: concept),
        const SizedBox(height: 24),

        _DepthSelector(
          selectedDepth: selectedDepth,
          onDepthChanged: onDepthChanged,
          theme: theme,
        ),
        const SizedBox(height: 24),
        objectsAsync.when(
          data: (objects) {
            final depthInfo = _depthLevels.firstWhere(
              (d) => d.level == selectedDepth,
            );
            final filtered = objects
                .where((o) => o.inferredDepth == selectedDepth)
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(depthInfo.icon, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(depthInfo.desc, style: theme.textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      '${filtered.length} items',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(depthInfo.icon,
                              size: 48,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.2)),
                          const SizedBox(height: 12),
                          Text(
                            'No ${depthInfo.label.toLowerCase()} content yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filtered.map((obj) {
                    switch (obj.objectType) {
                      case 'quiz':
                        return _QuizCard(object: obj, theme: theme);
                      case 'flashcard':
                        return _FlashcardWidget(object: obj, theme: theme);
                      default:
                        return _ContentCard(object: obj, theme: theme);
                    }
                  }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Failed to load content: $e'),
        ),
        const SizedBox(height: 24),
        // Related Concepts section
        _RelatedConcepts(conceptId: concept.id),
      ],
    );
  }
}

/// Quick action buttons below the concept summary (Explore, Ask AI, Quiz me)
class _ConceptActions extends StatelessWidget {
  final ConceptModel concept;
  const _ConceptActions({required this.concept});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ActionChip(
          avatar: Icon(Icons.explore, size: 18, color: theme.colorScheme.primary),
          label: const Text('Explore'),
          onPressed: () {},
        ),
        ActionChip(
          avatar: Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.secondary),
          label: const Text('Ask AI'),
          onPressed: () {
            // Navigate to AI tutor with concept context
          },
        ),
        ActionChip(
          avatar: const Icon(Icons.quiz, size: 18, color: Colors.orange),
          label: const Text('Quiz me'),
          onPressed: () {},
        ),
        ActionChip(
          avatar: Icon(Icons.account_tree, size: 18, color: theme.colorScheme.primary),
          label: const Text('Prerequisites'),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _DepthSelector extends StatelessWidget {
  final int selectedDepth;
  final ValueChanged<int> onDepthChanged;
  final ThemeData theme;

  const _DepthSelector({
    required this.selectedDepth,
    required this.onDepthChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _depthLevels.map((d) {
          final isSelected = d.level == selectedDepth;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(d.icon, size: 16),
              label: Text(d.label),
              selected: isSelected,
              onSelected: (_) => onDepthChanged(d.level),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final LearningObjectModel object;
  final ThemeData theme;

  const _ContentCard({required this.object, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_iconForType(object.objectType),
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(object.title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              object.content['body'] as String? ?? '',
              style: theme.textTheme.bodyLarge,
            ),
            if (object.content['key_points'] != null) ...[
              const SizedBox(height: 12),
              ...((object.content['key_points'] as List)
                      .cast<String>()
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(child: Text(p)),
                              ],
                            ),
                          ))),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'card' => Icons.auto_stories,
      'article' => Icons.article,
      'explanation' => Icons.psychology,
      'story' => Icons.menu_book,
      'diagram' => Icons.bubble_chart,
      'flowchart' => Icons.account_tree,
      'timeline' => Icons.timeline,
      _ => Icons.description,
    };
  }
}

/// Flashcard widget with flip animation
class _FlashcardWidget extends StatefulWidget {
  final LearningObjectModel object;
  final ThemeData theme;

  const _FlashcardWidget({required this.object, required this.theme});

  @override
  State<_FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<_FlashcardWidget> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final front = widget.object.content['front'] as String? ?? widget.object.title;
    final back = widget.object.content['back'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: widget.theme.colorScheme.secondary.withValues(alpha: 0.05),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _showAnswer = !_showAnswer),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flip, color: widget.theme.colorScheme.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text('Flashcard', style: widget.theme.textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    _showAnswer ? 'Tap to flip' : 'Tap to reveal',
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedCrossFade(
                firstChild: Text(front, style: widget.theme.textTheme.bodyLarge),
                secondChild: Text(back, style: widget.theme.textTheme.bodyLarge?.copyWith(
                  color: widget.theme.colorScheme.primary,
                )),
                crossFadeState:
                    _showAnswer ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quiz card that supports ALL questions with pagination
class _QuizCard extends StatefulWidget {
  final LearningObjectModel object;
  final ThemeData theme;

  const _QuizCard({required this.object, required this.theme});

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  int _currentQuestion = 0;
  int? _selected;
  bool _submitted = false;
  int _correctCount = 0;
  bool _quizComplete = false;

  List<Map> get _questions =>
      (widget.object.content['questions'] as List?)?.cast<Map>() ?? [];

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) return const SizedBox.shrink();

    if (_quizComplete) {
      return _QuizResults(
        theme: widget.theme,
        correctCount: _correctCount,
        totalCount: _questions.length,
        onRetry: () => setState(() {
          _currentQuestion = 0;
          _selected = null;
          _submitted = false;
          _correctCount = 0;
          _quizComplete = false;
        }),
      );
    }

    final current = _questions[_currentQuestion];
    final options = (current['options'] as List?)?.cast<String>() ?? [];
    final correctIndex = current['correct_index'] as int?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: widget.theme.colorScheme.primary.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz,
                    color: widget.theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Quiz', style: widget.theme.textTheme.titleMedium),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentQuestion + 1} / ${_questions.length}',
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Progress bar
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _questions.length,
              backgroundColor: widget.theme.colorScheme.primary.withValues(alpha: 0.1),
              color: widget.theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Text(current['question'] as String? ?? '',
                style: widget.theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            ...List.generate(options.length, (i) {
              final isCorrect = _submitted && i == correctIndex;
              final isWrong =
                  _submitted && i == _selected && i != correctIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ChoiceChip(
                  label: Text(options[i]),
                  selected: _selected == i,
                  selectedColor: isCorrect
                      ? Colors.green.withValues(alpha: 0.3)
                      : isWrong
                          ? Colors.red.withValues(alpha: 0.3)
                          : null,
                  onSelected: _submitted
                      ? null
                      : (val) {
                          setState(() => _selected = i);
                        },
                ),
              );
            }),
            const SizedBox(height: 8),
            if (!_submitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () {
                          setState(() {
                            _submitted = true;
                            if (_selected == correctIndex) {
                              _correctCount++;
                            }
                          });
                        },
                  child: const Text('Check Answer'),
                ),
              )
            else
              Row(
                children: [
                  Icon(
                    _selected == correctIndex
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: _selected == correctIndex
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selected == correctIndex
                          ? 'Correct!'
                          : 'Incorrect — the answer is "${options[correctIndex ?? 0]}"',
                      style: TextStyle(
                        color: _selected == correctIndex
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (_currentQuestion < _questions.length - 1) {
                        setState(() {
                          _currentQuestion++;
                          _selected = null;
                          _submitted = false;
                        });
                      } else {
                        setState(() => _quizComplete = true);
                      }
                    },
                    child: Text(
                      _currentQuestion < _questions.length - 1
                          ? 'Next'
                          : 'See Results',
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Quiz results summary
class _QuizResults extends StatelessWidget {
  final ThemeData theme;
  final int correctCount;
  final int totalCount;
  final VoidCallback onRetry;

  const _QuizResults({
    required this.theme,
    required this.correctCount,
    required this.totalCount,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (correctCount / totalCount * 100).round();
    final passed = percentage >= 70;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: (passed ? Colors.green : Colors.orange).withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              passed ? Icons.celebration : Icons.refresh,
              size: 48,
              color: passed ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              passed ? 'Great job!' : 'Keep practicing!',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '$correctCount / $totalCount correct ($percentage%)',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Related Concepts section — shows concept relationships from the knowledge graph
class _RelatedConcepts extends ConsumerWidget {
  final String conceptId;
  const _RelatedConcepts({required this.conceptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final relatedAsync = ref.watch(relatedConceptsProvider(conceptId));

    return relatedAsync.when(
      data: (related) {
        if (related.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Related Concepts',
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...related.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _colorForRelType(
                                r.relationship.relationshipType)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        r.relationship.typeLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _colorForRelType(
                              r.relationship.relationshipType),
                        ),
                      ),
                    ),
                    title: Text(r.concept.title),
                    subtitle: r.concept.summary != null
                        ? Text(r.concept.summary!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        GoRouter.of(context).go('/concept/${r.concept.slug}'),
                  ),
                )),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _colorForRelType(String type) {
    return switch (type) {
      'prerequisite_of' => const Color(0xFFFF6B6B),
      'related_to' => const Color(0xFF6C63FF),
      'example_of' => const Color(0xFF00D9A6),
      'part_of' => const Color(0xFF4A90D9),
      'extends' => const Color(0xFF8B83FF),
      'applies_to' => const Color(0xFFFF8C42),
      'similar_to' => const Color(0xFF00E6B3),
      _ => const Color(0xFF6C63FF),
    };
  }
}
