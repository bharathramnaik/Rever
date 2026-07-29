import 'package:flutter/foundation.dart';
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
                            redirectTo: kIsWeb
                                ? Uri.base.toString()
                                : 'com.rever.rever://callback',
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
                onPressed: () => _showEmailAuthDialog(context, ref),
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

void _showEmailAuthDialog(BuildContext context, WidgetRef ref) {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  var isSignUp = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(isSignUp ? 'Create Account' : 'Sign In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'At least 6 characters',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => isSignUp = !isSignUp),
              child: Text(
                isSignUp
                    ? 'Already have an account? Sign in'
                    : 'New here? Create an account',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final email = emailCtrl.text.trim();
              final password = passCtrl.text;
              if (email.isEmpty || password.isEmpty) return;

              try {
                final supabase = ref.read(supabaseProvider);
                if (isSignUp) {
                  await supabase.auth.signUp(email: email, password: password);
                } else {
                  await supabase.auth.signInWithPassword(
                      email: email, password: password);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              }
            },
            child: Text(isSignUp ? 'Sign Up' : 'Sign In'),
          ),
        ],
      ),
    ),
  );
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
