import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

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
              Text(
                'What do you want to learn?',
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search any topic...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Topics', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: _topics.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                            Icon(_topics[index].icon, size: 28, color: _topics[index].color),
                              const SizedBox(height: 8),
                              Text(
                                _topics[index].name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Topic {
  final String name;
  final IconData icon;
  final Color color;
  const _Topic(this.name, this.icon, this.color);
}

const _topics = [
  _Topic('Technology', Icons.code, Color(0xFF6C63FF)),
  _Topic('Science', Icons.biotech, Color(0xFF00D9A6)),
  _Topic('Mathematics', Icons.calculate, Color(0xFFFF6B6B)),
  _Topic('History', Icons.history, Color(0xFFFFD93D)),
  _Topic('Psychology', Icons.psychology, Color(0xFF8B83FF)),
  _Topic('Finance', Icons.account_balance, Color(0xFF00E6B3)),
  _Topic('Philosophy', Icons.self_improvement, Color(0xFFFF8C42)),
  _Topic('Space', Icons.rocket_launch, Color(0xFF4A90D9)),
];
