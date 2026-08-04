import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/core/theme/theme.dart';
import 'package:rever/src/data/providers/preferences_provider.dart';
import 'package:rever/src/data/providers/streak_providers.dart';
import 'package:rever/src/data/providers/progress_providers.dart';

class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileId = ref.watch(activeProfileIdProvider);
    final profileAsync = ref.watch(activeProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              profileAsync.when(
                data: (profile) => Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primary,
                      child: profile?.avatarUrl != null
                          ? ClipOval(
                              child: Image.network(profile!.avatarUrl!,
                                  width: 64, height: 64, fit: BoxFit.cover),
                            )
                          : Text(
                              (profile?.name ?? profileId ?? 'L')[0]
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 28,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.name ?? profileId ?? 'Learner',
                            style: theme.textTheme.headlineMedium,
                          ),
                          Text(
                            _profileTypeLabel(
                              profile?.profileType ?? 'adult',
                              profile?.ageRange,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          if (profile != null)
                            Text(
                              'Daily goal: ${profile.dailyGoalMinutes} min',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.go('/profiles'),
                    ),
                  ],
                ),
                loading: () => _StaticHeader(
                  theme: theme,
                  name: profileId ?? 'Learner',
                ),
                error: (_, __) => _StaticHeader(
                  theme: theme,
                  name: profileId ?? 'Learner',
                ),
              ),

              const SizedBox(height: 32),
              Text('Progress', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),

              // Real stats from providers
              if (profileId != null) ...[
                _LiveStatCard(
                  theme: theme,
                  icon: Icons.auto_stories,
                  label: 'Concepts Completed',
                  provider: conceptsCompletedProvider(profileId),
                  formatter: (v) => '$v',
                  sub: 'Learning objects completed',
                ),
                const SizedBox(height: 12),
                _StreakStatCard(theme: theme, profileId: profileId),
                const SizedBox(height: 12),
                _LiveStatCard(
                  theme: theme,
                  icon: Icons.timer_outlined,
                  label: 'Total Learning Time',
                  provider: totalLearningTimeProvider(profileId),
                  formatter: (v) => '$v min',
                  sub: 'Time spent learning',
                ),
                const SizedBox(height: 12),
                _LiveStatCard(
                  theme: theme,
                  icon: Icons.workspace_premium,
                  label: 'Mastered',
                  provider: conceptsMasteredProvider(profileId),
                  formatter: (v) => '$v concepts',
                  sub: 'Concepts with 70%+ mastery',
                ),
              ] else ...[
                _StatCard(
                  theme: theme,
                  icon: Icons.person_outline,
                  label: 'No Profile Selected',
                  value: '—',
                  sub: 'Select a profile to see your progress',
                ),
              ],

              const SizedBox(height: 32),
              Text('Settings', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              _SettingsTile(
                icon: Icons.swap_horiz,
                title: 'Switch Profile',
                onTap: () => context.go('/profiles'),
              ),
              _InterestsTile(),
              _SettingsTile(
                icon: Icons.tune,
                title: 'Preferences',
                onTap: () => _showPreferencesDialog(context),
              ),
              _ThemeSettingsTile(),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon!')),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.replay,
                title: 'Spaced Review',
                subtitle: 'Review concepts due today',
                onTap: () => context.go('/review'),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Rever',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 Rever',
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'Learn anything. Remember everything. '
                          'Rever transforms complex knowledge into bite-sized, '
                          'visual learning experiences with AI-powered micro-learning '
                          'and spaced repetition.',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _profileTypeLabel(String type, String? ageRange) {
    final label = '${type[0].toUpperCase()}${type.substring(1)} Profile';
    if (ageRange != null) return '$label • Age $ageRange';
    return label;
  }

  void _showPreferencesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Preferences'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Daily Learning Goal'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [10, 15, 20, 30].map((min) {
                return ChoiceChip(
                  label: Text('$min min'),
                  selected: min == 15,
                  onSelected: (_) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Daily goal set to $min minutes')),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StaticHeader extends StatelessWidget {
  final ThemeData theme;
  final String name;

  const _StaticHeader({required this.theme, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            name[0].toUpperCase(),
            style: TextStyle(fontSize: 28, color: theme.colorScheme.onPrimary),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: theme.textTheme.headlineMedium),
            Text('Profile',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          ],
        ),
      ],
    );
  }
}

/// Stat card that reads from a FutureProvider for real data
class _LiveStatCard extends ConsumerWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final FutureProvider<int> provider;
  final String Function(int) formatter;
  final String sub;

  const _LiveStatCard({
    required this.theme,
    required this.icon,
    required this.label,
    required this.provider,
    required this.formatter,
    required this.sub,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valueAsync = ref.watch(provider);
    return _StatCard(
      theme: theme,
      icon: icon,
      label: label,
      value: valueAsync.when(
        data: (v) => formatter(v),
        loading: () => '...',
        error: (_, __) => '0',
      ),
      sub: sub,
    );
  }
}

/// Streak card that uses the streak provider
class _StreakStatCard extends ConsumerWidget {
  final ThemeData theme;
  final String profileId;

  const _StreakStatCard({required this.theme, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider(profileId));
    return _StatCard(
      theme: theme,
      icon: Icons.local_fire_department,
      label: 'Streak',
      value: streakAsync.when(
        data: (s) => '${s?.currentStreak ?? 0} days',
        loading: () => '...',
        error: (_, __) => '0 days',
      ),
      sub: streakAsync.when(
        data: (s) {
          if (s == null || s.currentStreak == 0) {
            return 'Start learning to build your streak';
          }
          return 'Longest: ${s.longestStreak} days • Total: ${s.totalLearningDays} days';
        },
        loading: () => 'Loading...',
        error: (_, __) => 'Start learning to build your streak',
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
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestsTile extends ConsumerWidget {
  const _InterestsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefs = ref.watch(activePreferencesProvider).asData?.value;
    final topicCount = prefs?.topics.length ?? 0;

    return ListTile(
      leading: Icon(
        topicCount > 0 ? Icons.interests : Icons.interests_outlined,
        color: topicCount > 0 ? theme.colorScheme.primary : null,
      ),
      title: const Text('Interests & Goals'),
      subtitle: Text(
        topicCount > 0
            ? '${prefs!.topics.length} topics · ${prefs.goal.isNotEmpty ? prefs.goal : 'no goal yet'}'
            : 'Personalize what you see',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/preferences?force=true'),
    );
  }
}

class _ThemeSettingsTile extends ConsumerWidget {
  const _ThemeSettingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    final label = switch (mode) {
      ReverThemeMode.system => 'Follow Device',
      ReverThemeMode.light => 'Light',
      ReverThemeMode.dark => 'Dark',
    };

    return ListTile(
      leading: Icon(mode == ReverThemeMode.dark
          ? Icons.dark_mode_outlined
          : Icons.light_mode_outlined),
      title: const Text('Theme'),
      subtitle: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context, ref),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final mode = ref.read(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    void select(ReverThemeMode m) {
      notifier.setMode(m);
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('App Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              label: 'Follow Device',
              subtitle: 'Uses your device dark/light setting',
              icon: Icons.brightness_auto_outlined,
              selected: mode == ReverThemeMode.system,
              onTap: () => select(ReverThemeMode.system),
            ),
            _ThemeOption(
              label: 'Light',
              icon: Icons.light_mode_outlined,
              selected: mode == ReverThemeMode.light,
              onTap: () => select(ReverThemeMode.light),
            ),
            _ThemeOption(
              label: 'Dark',
              icon: Icons.dark_mode_outlined,
              selected: mode == ReverThemeMode.dark,
              onTap: () => select(ReverThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: selected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
