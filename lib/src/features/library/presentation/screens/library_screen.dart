import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

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
              Text('Your Library', style: theme.textTheme.displayLarge),
              const SizedBox(height: 24),
              const _LibraryTab(label: 'All', count: 12),
              const _LibraryTab(label: 'Saved', count: 8),
              const _LibraryTab(label: 'Notes', count: 3),
              const _LibraryTab(label: 'History', count: 47),
              const Spacer(),
              Center(
                child: Text(
                  'Start learning to build your library',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryTab extends StatelessWidget {
  final String label;
  final int count;

  const _LibraryTab({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        child: ListTile(
          title: Text(label),
          trailing: Text(
            '$count',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
