import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateScreen extends ConsumerWidget {
  const CreateScreen({super.key});

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
              Text('Create', style: theme.textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(
                'Build your knowledge',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              _CreateOption(
                icon: Icons.auto_awesome,
                title: 'Ask AI Tutor',
                subtitle: 'Chat with an AI tutor about any topic',
                color: theme.colorScheme.primary,
                onTap: () => context.go('/ai-tutor'),
              ),
              const SizedBox(height: 12),
              _CreateOption(
                icon: Icons.collections_bookmark,
                title: 'Learning Space',
                subtitle: 'Create a collection of concepts around a theme',
                color: theme.colorScheme.secondary,
                onTap: () => _showCreateSpaceDialog(context),
              ),
              const SizedBox(height: 12),
              _CreateOption(
                icon: Icons.edit_note,
                title: 'Quick Note',
                subtitle: 'Capture a thought or insight while learning',
                color: Colors.orange,
                onTap: () => _showCreateNoteDialog(context),
              ),
              const SizedBox(height: 12),
              _CreateOption(
                icon: Icons.quiz,
                title: 'Custom Quiz',
                subtitle: 'Test yourself on what you\'ve learned',
                color: Colors.purple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Custom quizzes coming soon!')),
                  );
                },
              ),
              const SizedBox(height: 12),
              _CreateOption(
                icon: Icons.route,
                title: 'Learning Path',
                subtitle: 'Plan a sequence of concepts to master a topic',
                color: const Color(0xFF4A90D9),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Learning paths coming soon!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateSpaceDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Learning Space'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Space Name',
            hintText: 'e.g., AI & Machine Learning',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Space "${nameController.text}" created! (DB integration coming)'),
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreateNoteDialog(BuildContext context) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quick Note'),
        content: TextField(
          controller: noteController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Your note',
            hintText: 'What did you learn today?',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (noteController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note saved!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
