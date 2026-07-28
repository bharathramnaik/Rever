import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.replay_circle_filled_outlined,
                  size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('No concepts due for review',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Start learning to build your review queue',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context, // will wire to Learn/Explore tab
                child: const Text('Explore Concepts'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
