import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/features/profile/presentation/screens/profile_switch_screen.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/models/profile_model.dart';

void main() {
  group('ProfileSwitchScreen', () {
    final testProfiles = [
      const ProfileModel(
        id: 'p1',
        accountId: 'a1',
        name: 'Bharath',
        avatarUrl: null,
        profileType: 'adult',
        ageRange: null,
        dailyGoalMinutes: 15,
      ),
      const ProfileModel(
        id: 'p2',
        accountId: 'a1',
        name: 'Arjun',
        avatarUrl: null,
        profileType: 'child',
        ageRange: '8',
        dailyGoalMinutes: 5,
      ),
      const ProfileModel(
        id: 'p3',
        accountId: 'a1',
        name: 'Nikhil',
        avatarUrl: null,
        profileType: 'teen',
        ageRange: '15',
        dailyGoalMinutes: 20,
      ),
    ];

    testWidgets('renders all profiles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profilesProvider.overrideWith((ref) async => testProfiles),
          ],
          child: const MaterialApp(home: ProfileSwitchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Who's learning?"), findsOneWidget);
      expect(find.text('Bharath'), findsOneWidget);
      expect(find.text('Arjun'), findsOneWidget);
      expect(find.text('Nikhil'), findsOneWidget);
    });

    testWidgets('renders add profile button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profilesProvider.overrideWith((ref) async => testProfiles),
          ],
          child: const MaterialApp(home: ProfileSwitchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Profile'), findsOneWidget);
    });

    testWidgets('renders profile type labels', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profilesProvider.overrideWith((ref) async => testProfiles),
          ],
          child: const MaterialApp(home: ProfileSwitchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Adult'), findsOneWidget);
      expect(find.text('Child (Age 8)'), findsOneWidget);
      expect(find.text('Teen (Age 15)'), findsOneWidget);
    });
  });
}
