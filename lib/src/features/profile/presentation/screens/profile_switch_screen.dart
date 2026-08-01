import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/models/profile_model.dart';

class ProfileSwitchScreen extends ConsumerWidget {
  const ProfileSwitchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profilesAsync = ref.watch(profilesProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/interests');
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
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
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),
                profilesAsync.when(
                  data: (profiles) {
                    if (profiles.isEmpty) {
                      return _EmptyProfiles(theme: theme);
                    }
                    return Column(
                      children: [
                        ...profiles.map((profile) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                                child: _ProfileCard(
                                  profile: profile,
                                  onTap: () {
                                    ref
                                        .read(activeProfileIdProvider.notifier)
                                        .select(profile.id);
                                    context.go('/preferences');
                                  },
                                ),
                            )),
                        OutlinedButton.icon(
                          onPressed: () => _showAddProfileDialog(context, ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Profile'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(64),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => _FallbackProfiles(
                    ref: ref,
                    onSelect: (id) {
                      ref.read(activeProfileIdProvider.notifier).select(id);
                      context.go('/preferences');
                    },
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => context.go('/auth'),
                  child: const Text('Account Settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddProfileDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String profileType = 'adult';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter profile name',
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'adult', label: Text('Adult')),
                  ButtonSegment(value: 'teen', label: Text('Teen')),
                  ButtonSegment(value: 'child', label: Text('Child')),
                ],
                selected: {profileType},
                onSelectionChanged: (v) =>
                    setState(() => profileType = v.first),
              ),
            ],
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
                  // Profile creation will be wired to Supabase
                  // For now, refresh the list
                  ref.invalidate(profilesProvider);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fallback when Supabase profiles can't be loaded (e.g., unauthenticated demo)
class _FallbackProfiles extends StatelessWidget {
  final WidgetRef ref;
  final ValueChanged<String> onSelect;

  const _FallbackProfiles({required this.ref, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final demoProfiles = [
      (name: 'Bharath', type: 'Adult', icon: Icons.face, color: const Color(0xFF6C63FF)),
      (name: 'Arjun', type: 'Child (Age 8)', icon: Icons.child_care, color: const Color(0xFF00D9A6)),
      (name: 'Nikhil', type: 'Teen (Age 15)', icon: Icons.school, color: const Color(0xFFFF6B6B)),
    ];

    return Column(
      children: demoProfiles
          .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _DemoProfileCard(
                  name: p.name,
                  type: p.type,
                  icon: p.icon,
                  color: p.color,
                  onTap: () => onSelect(p.name),
                ),
              ))
          .toList(),
    );
  }
}

class _EmptyProfiles extends StatelessWidget {
  final ThemeData theme;
  const _EmptyProfiles({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.person_add, size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No profiles yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Create a profile to start learning',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              )),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onTap;

  const _ProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(profile.profileType);
    final icon = _iconForType(profile.profileType);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color.withValues(alpha: 0.1),
          child: profile.avatarUrl != null
              ? ClipOval(
                  child: Image.network(profile.avatarUrl!,
                      width: 56, height: 56, fit: BoxFit.cover),
                )
              : Icon(icon, color: color, size: 28),
        ),
        title: Text(profile.name, style: theme.textTheme.headlineMedium),
        subtitle: Text(
          _typeLabel(profile.profileType, profile.ageRange),
          style: theme.textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _typeLabel(String type, String? ageRange) {
    final label = type[0].toUpperCase() + type.substring(1);
    if (ageRange != null) return '$label (Age $ageRange)';
    return label;
  }

  Color _colorForType(String type) {
    return switch (type) {
      'child' => const Color(0xFF00D9A6),
      'teen' => const Color(0xFFFF6B6B),
      _ => const Color(0xFF6C63FF),
    };
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'child' => Icons.child_care,
      'teen' => Icons.school,
      _ => Icons.face,
    };
  }
}

class _DemoProfileCard extends StatelessWidget {
  final String name;
  final String type;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DemoProfileCard({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
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
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(name, style: theme.textTheme.headlineMedium),
        subtitle: Text(type, style: theme.textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
