import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/data/providers/topic_providers.dart';
import 'package:rever/src/data/models/topic_model.dart';

IconData _iconFromName(String? name) {
  return switch (name) {
    'code' => Icons.code,
    'biotech' => Icons.biotech,
    'calculate' => Icons.calculate,
    'history' => Icons.history,
    'psychology' => Icons.psychology,
    'account_balance' => Icons.account_balance,
    'self_improvement' => Icons.self_improvement,
    'rocket_launch' => Icons.rocket_launch,
    'palette' => Icons.palette,
    'favorite' => Icons.favorite,
    'forest' || 'nature_people' => Icons.nature,
    'precision_manufacturing' || 'engineering' => Icons.build,
    _ => Icons.explore,
  };
}

Color _colorFromString(String? color) {
  if (color == null) return const Color(0xFF6C63FF);
  final hex = color.replaceFirst('#', '');
  if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
  return const Color(0xFF6C63FF);
}

class InterestSelectionScreen extends ConsumerStatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  ConsumerState<InterestSelectionScreen> createState() =>
      _InterestSelectionScreenState();
}

class _InterestSelectionScreenState
    extends ConsumerState<InterestSelectionScreen> {
  final Set<String> _selectedTopicIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topicsAsync = ref.watch(topicsProvider);


    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What interests you?',
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Pick at least 3 topics to personalize your feed',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: topicsAsync.when(
                  data: (topics) => GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.6,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      final isSelected =
                          _selectedTopicIds.contains(topic.id);
                      return _InterestChip(
                        topic: topic,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedTopicIds.remove(topic.id);
                            } else {
                              _selectedTopicIds.add(topic.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('$e')),
                ),
              ),
              const SizedBox(height: 16),
              // Selection count
              Center(
                child: Text(
                  '${_selectedTopicIds.length} selected',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _selectedTopicIds.length >= 3
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: _selectedTopicIds.length >= 3
                        ? FontWeight.w600
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedTopicIds.length >= 3
                      ? () {
                          // Interests are selected — navigate to profile selection
                          // In a full implementation, save to Supabase
                          context.go('/profiles');
                        }
                      : null,
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/profiles'),
                  child: const Text('Skip for now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final TopicModel topic;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestChip({
    required this.topic,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _iconFromName(topic.icon);
    final color = _colorFromString(topic.color);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : theme.colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 24, color: color),
                  if (isSelected)
                    Icon(Icons.check_circle, size: 20, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                topic.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
