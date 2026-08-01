import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/models/preferences_model.dart';
import 'package:rever/src/data/repositories/preference_repository.dart';
import 'package:rever/src/data/providers/preferences_provider.dart';
import 'package:rever/src/features/onboarding/presentation/screens/preference_quiz_screen.dart';

class _FakePreferenceRepository implements PreferenceRepository {
  PreferencesModel? saved;
  bool savedCalled = false;

  @override
  Future<PreferencesModel?> fetch(String profileId) async => saved;

  @override
  Future<void> save(PreferencesModel preferences) async {
    saved = preferences;
    savedCalled = true;
  }
}

void main() {
  final fakeRepo = _FakePreferenceRepository();

  setUp(() {
    fakeRepo.saved = null;
    fakeRepo.savedCalled = false;
  });

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/preferences',
      routes: [
        GoRoute(
          path: '/preferences',
          builder: (_, __) => const PreferenceQuizScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('HOME')),
        ),
        GoRoute(
          path: '/profiles',
          builder: (_, __) => const Scaffold(body: Text('PROFILES')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        activeProfileIdProvider.overrideWith(() => _ActiveIdNotifier()),
        preferenceRepositoryProvider.overrideWith((ref) => fakeRepo),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('quiz walks through all steps and saves preferences',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('What are you most interested in?'), findsOneWidget);

    await tester.tap(find.text('Science'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text("What's your main goal?"), findsOneWidget);

    await tester.tap(find.text('Stay curious'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('How do you like to learn?'), findsOneWidget);

    await tester.tap(find.text('Quick ideas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('How many ideas a day?'), findsOneWidget);

    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start learning'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(fakeRepo.savedCalled, isTrue);
    expect(fakeRepo.saved!.topics, contains('Science'));
    expect(fakeRepo.saved!.goal, 'Stay curious');
    expect(fakeRepo.saved!.learningStyle, 'Quick ideas');
    expect(fakeRepo.saved!.dailyGoalIdeas, 5);
  });

  testWidgets('skip saves default preferences and goes home',
      (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(fakeRepo.savedCalled, isTrue);
    expect(fakeRepo.saved!.topics, isEmpty);
  });
}

class _ActiveIdNotifier extends ActiveProfileNotifier {
  @override
  String? build() => 'test-profile-id';
}
