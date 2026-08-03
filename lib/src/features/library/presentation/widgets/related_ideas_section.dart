import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/providers/idea_relationship_providers.dart';

/// "Related ideas" section for the reel (flow.txt §5 knowledge graph).
/// Renders the connected cards with direction-aware type labels.
class RelatedIdeasSection extends ConsumerWidget {
  final RelatedSeed seed;

  const RelatedIdeasSection({super.key, required this.seed});

  Color _colorFor(String type) => switch (type) {
        'contradicts' => Colors.redAccent,
        'supports' => Colors.greenAccent,
        'prerequisite_of' => const Color(0xFFFF6B6B),
        'related_to' => Colors.cyanAccent,
        'example_of' => Colors.amberAccent,
        'applies_to' => Colors.purpleAccent,
        _ => Colors.cyanAccent,
      };

  IconData _iconFor(String type) => switch (type) {
        'contradicts' => Icons.call_split,
        'supports' => Icons.extension,
        'prerequisite_of' => Icons.account_tree,
        'related_to' => Icons.link,
        'example_of' => Icons.lightbulb_outline,
        'applies_to' => Icons.arrow_forward,
        _ => Icons.link,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(relatedIdeasProvider(seed));
    return async.when(
      data: (ideas) {
        if (ideas.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.cyanAccent.withValues(alpha: 0.4),
                width: 3,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.hub_outlined,
                      size: 18, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Related ideas',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.4,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final idea in ideas.take(4)) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_iconFor(idea.relationshipType),
                        size: 16, color: _colorFor(idea.relationshipType)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${idea.typeLabel}: ',
                              style: TextStyle(
                                color: _colorFor(idea.relationshipType),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: idea.card.takeaway,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (idea != ideas.take(4).last) const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
