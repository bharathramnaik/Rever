import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(activeProfileIdProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      (profile ?? 'L')[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile ?? 'Learner',
                        style: theme.textTheme.headlineMedium,
                      ),
                      Text(
                        'Adult Profile',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => context.go('/profiles'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text('Progress', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              _StatCard(
                theme: theme,
                icon: Icons.auto_stories,
                label: 'Concepts',
                value: '0',
                sub: 'No concepts completed yet',
              ),
              const SizedBox(height: 12),
              _StatCard(
                theme: theme,
                icon: Icons.local_fire_department,
                label: 'Streak',
                value: '0 days',
                sub: 'Start learning to build your streak',
              ),
              const SizedBox(height: 12),
              _StatCard(
                theme: theme,
                icon: Icons.timer_outlined,
                label: 'Time',
                value: '0 min',
                sub: 'Total learning time',
              ),
              const SizedBox(height: 32),
              Text('Settings', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              _SettingsTile(
                icon: Icons.swap_horiz,
                title: 'Switch Profile',
                onTap: () => context.go('/profiles'),
              ),
              _SettingsTile(
                icon: Icons.tune,
                title: 'Preferences',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const _StatCard({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                )),
                Text(label, style: theme.textTheme.bodyMedium),
                Text(sub,
                    style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
