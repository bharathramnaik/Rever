import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConceptScreen extends ConsumerWidget {
  final String conceptId;

  const ConceptScreen({super.key, required this.conceptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
        actions: [
          IconButton(icon: const Icon(Icons.bookmark_outline), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Concept title
          Text('How Transformers Work', style: theme.textTheme.displayLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              const Chip(label: Text('AI'), visualDensity: VisualDensity.compact),
              const SizedBox(width: 8),
              const Chip(label: Text('Beginner'), visualDensity: VisualDensity.compact),
              const Spacer(),
              Text('5 min read', style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 24),

          // Mode selector
          Row(
            children: [
              _ModeButton(theme: theme, label: 'Read', icon: Icons.menu_book, selected: true),
              const SizedBox(width: 8),
              _ModeButton(theme: theme, label: 'Visual', icon: Icons.bubble_chart, selected: false),
              const SizedBox(width: 8),
              _ModeButton(theme: theme, label: 'Quiz', icon: Icons.quiz, selected: false),
              const SizedBox(width: 8),
              _ModeButton(theme: theme, label: 'Ask AI', icon: Icons.auto_awesome, selected: false),
            ],
          ),
          const SizedBox(height: 24),

          // Content placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(Icons.image, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            ),
          ),
          const SizedBox(height: 24),

          // Key points
          Text('Key Points', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          const _KeyPoint(
            number: '1',
            text: 'Transformers are a neural network architecture introduced in 2017',
          ),
          const _KeyPoint(
            number: '2',
            text: 'They use self-attention to process sequential data in parallel',
          ),
          const _KeyPoint(
            number: '3',
            text: 'They power modern AI systems like GPT, BERT, and Claude',
          ),

          const SizedBox(height: 24),

          // Related concepts
          Text('Related Concepts', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          _RelatedChip(theme: theme, label: 'Neural Networks'),
          _RelatedChip(theme: theme, label: 'Deep Learning'),
          _RelatedChip(theme: theme, label: 'Attention Mechanism'),
          _RelatedChip(theme: theme, label: 'Large Language Models'),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final IconData icon;
  final bool selected;

  const _ModeButton({
    required this.theme,
    required this.label,
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyPoint extends StatelessWidget {
  final String number;
  final String text;

  const _KeyPoint({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _RelatedChip extends StatelessWidget {
  final ThemeData theme;
  final String label;

  const _RelatedChip({required this.theme, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ActionChip(
        label: Text(label),
        onPressed: () {},
      ),
    );
  }
}
