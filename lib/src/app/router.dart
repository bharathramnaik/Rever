import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/screens/home_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/screens/profile_switch_screen.dart';
import '../features/profile/presentation/screens/me_screen.dart';
import '../features/explore/presentation/screens/explore_screen.dart';
import '../features/explore/presentation/screens/topic_screen.dart';
import '../features/library/presentation/screens/library_screen.dart';
import '../features/spaces/presentation/screens/create_screen.dart';
import '../features/ai_tutor/presentation/screens/ai_tutor_screen.dart';
import '../features/concept/presentation/screens/concept_screen.dart';
import '../features/sources/presentation/screens/sources_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/profiles',
        builder: (context, state) => const ProfileSwitchScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/learn',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/create',
            builder: (context, state) => const CreateScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/me',
            builder: (context, state) => const MeScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/topic/:slug',
        builder: (context, state) => TopicScreen(
          slug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '/concept/:id',
        builder: (context, state) => ConceptScreen(
          conceptId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/sources',
        builder: (context, state) => const SourcesScreen(),
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onTabSelected(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith('/home')) return 0;
    if (uri.startsWith('/learn')) return 1;
    if (uri.startsWith('/create')) return 2;
    if (uri.startsWith('/library')) return 3;
    if (uri.startsWith('/me')) return 4;
    return 0;
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/learn');
      case 2:
        context.go('/create');
      case 3:
        context.go('/library');
      case 4:
        context.go('/me');
    }
  }
}
