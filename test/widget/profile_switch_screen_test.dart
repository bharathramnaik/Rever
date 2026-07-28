import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/features/profile/presentation/screens/profile_switch_screen.dart';

void main() {
  group('ProfileSwitchScreen', () {
    testWidgets('renders all profiles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: ProfileSwitchScreen()),
        ),
      );

      expect(find.text("Who's learning?"), findsOneWidget);
      expect(find.text('Bharath'), findsOneWidget);
      expect(find.text('Arjun'), findsOneWidget);
      expect(find.text('Nikhil'), findsOneWidget);
    });

    testWidgets('renders add profile button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: ProfileSwitchScreen()),
        ),
      );

      expect(find.text('Add Profile'), findsOneWidget);
    });

    testWidgets('renders profile type labels', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(home: ProfileSwitchScreen()),
        ),
      );

      expect(find.text('Adult'), findsOneWidget);
      expect(find.text('Child (Age 8)'), findsOneWidget);
      expect(find.text('Teen (Age 15)'), findsOneWidget);
    });
  });
}
