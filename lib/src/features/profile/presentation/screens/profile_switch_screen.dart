import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileSwitchScreen extends ConsumerWidget {
  const ProfileSwitchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Who\'s learning?',
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Select a profile to continue',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              _ProfileCard(
                name: 'Bharath',
                type: 'Adult',
                emoji: '👨‍💻',
                onTap: () => context.go('/home'),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                name: 'Arjun',
                type: 'Child (Age 8)',
                emoji: '👦',
                onTap: () => context.go('/home'),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                name: 'Nikhil',
                type: 'Teen (Age 15)',
                emoji: '🧑‍🎓',
                onTap: () => context.go('/home'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Profile'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Account Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String type;
  final String emoji;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.name,
    required this.type,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Text(emoji, style: const TextStyle(fontSize: 28)),
        ),
        title: Text(name, style: theme.textTheme.headlineMedium),
        subtitle: Text(type, style: theme.textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
