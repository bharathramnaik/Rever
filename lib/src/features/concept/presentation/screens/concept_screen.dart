import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/providers/concept_providers.dart';
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
          IconButton(icon: const Icon(Icons.bookmark_outline), onPressed: () {}),
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
            Text(object.title, style: theme.textTheme.titleMedium),
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
}

class _QuizCard extends StatefulWidget {
  final LearningObjectModel object;
  final ThemeData theme;

  const _QuizCard({required this.object, required this.theme});

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  int? _selected;
  bool? _submitted;

  @override
  Widget build(BuildContext context) {
    final questions =
        (widget.object.content['questions'] as List?)?.cast<Map>() ?? [];
    if (questions.isEmpty) return const SizedBox.shrink();

    final current = questions[0];
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
                Text('Quick Quiz', style: widget.theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Text(current['question'] as String? ?? '',
                style: widget.theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            ...List.generate(options.length, (i) {
              final isCorrect = _submitted == true && i == correctIndex;
              final isWrong = _submitted == true && i == _selected && i != correctIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ChoiceChip(
                  label: Text(options[i]),
                  selected: _selected == i,
                  selectedColor: isCorrect
                      ? Colors.green
                      : isWrong
                          ? Colors.red
                          : null,
                  onSelected: _submitted == true
                      ? null
                      : (val) {
                          setState(() => _selected = i);
                        },
                ),
              );
            }),
            const SizedBox(height: 8),
            if (_submitted == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () {
                          setState(() => _submitted = true);
                        },
                  child: const Text('Check Answer'),
                ),
              )
            else
              Text(
                _selected == correctIndex ? 'Correct!' : 'Incorrect',
                style: TextStyle(
                  color: _selected == correctIndex ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
