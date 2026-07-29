import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/profile_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final supabase = ref.watch(supabaseProvider);
    final authAsync = ref.watch(authStateProvider);

    ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) {
      final user = next.hasValue ? next.value : null;
      final wasUnauthed = prev == null || !prev.hasValue || prev.value == null;
      if (user != null && wasUnauthed) {
        _handleAuthSuccess(context, ref, user);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profiles'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rever',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Personal Learning OS',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              authAsync.isLoading
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                      onPressed: () async {
                        try {
                          await supabase.auth.signInWithOAuth(
                            OAuthProvider.google,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Sign in failed: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                    ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.email_outlined),
                label: const Text('Continue with Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _handleAuthSuccess(
    BuildContext context, WidgetRef ref, User user) async {
  try {
    final client = ref.read(supabaseProvider);
    final existingProfiles = await client
        .from('profiles')
        .select()
        .eq('account_id', user.id)
        .limit(1);

    if (existingProfiles.isEmpty) {
      final avatarUrl = user.userMetadata?['avatar_url'] as String?;
      final name = user.userMetadata?['full_name'] as String? ?? 'Me';

      await client.from('profiles').insert({
        'account_id': user.id,
        'name': name,
        'avatar_url': avatarUrl,
        'profile_type': 'adult',
        'daily_goal_minutes': 10,
      });
    }

    ref.invalidate(profilesProvider);

    if (context.mounted) {
      context.go('/profiles');
    }
  } catch (e) {
    debugPrint('[Auth] Profile creation error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile setup failed: $e')),
      );
    }
  }
}
