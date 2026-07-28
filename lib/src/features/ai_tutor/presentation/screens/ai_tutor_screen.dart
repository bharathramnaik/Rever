import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiTutorScreen extends ConsumerWidget {
  const AiTutorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('AI Tutor', style: theme.textTheme.displayLarge),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ask me anything about what you\'re learning',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _SuggestionChip(
                      theme: theme,
                      label: 'Explain how transformers work',
                      icon: Icons.auto_stories,
                    ),
                    _SuggestionChip(
                      theme: theme,
                      label: 'What is the difference between AI and ML?',
                      icon: Icons.psychology,
                    ),
                    _SuggestionChip(
                      theme: theme,
                      label: 'Give me a real-world example of neural networks',
                      icon: Icons.lightbulb,
                    ),
                    _SuggestionChip(
                      theme: theme,
                      label: 'Why is gravity important?',
                      icon: Icons.science,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Ask AI Tutor...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final IconData icon;

  const _SuggestionChip({
    required this.theme,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
