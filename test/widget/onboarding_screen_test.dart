import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders onboarding pages', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OnboardingScreen()),
        ),
      );

      expect(find.text('Learn Anything'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('navigates through pages', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OnboardingScreen()),
        ),
      );

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('shows page indicators', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OnboardingScreen()),
        ),
      );

      expect(find.byType(PageView), findsOneWidget);
    });
  });
}
