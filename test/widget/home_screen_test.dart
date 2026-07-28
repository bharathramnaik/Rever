import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/features/home/presentation/screens/home_screen.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/providers/concept_providers.dart';
import '../helpers/test_data.dart';

class _BharathNotifier extends ActiveProfileIdNotifier {
  @override
  String? build() => 'Bharath';
}

void main() {
  group('HomeScreen', () {
    testWidgets('renders greeting with profile name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeProfileIdProvider.overrideWith(_BharathNotifier.new),
            allConceptsProvider.overrideWith((ref) async => testConcepts),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Bharath'), findsOneWidget);
    });

    testWidgets('renders greeting with default name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allConceptsProvider.overrideWith((ref) async => testConcepts),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Learner'), findsOneWidget);
    });

    testWidgets('renders daily journey section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allConceptsProvider.overrideWith((ref) async => testConcepts),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Your 10-minute Journey'), findsOneWidget);
    });

    testWidgets('renders explore concepts section', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allConceptsProvider.overrideWith((ref) async => testConcepts),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Explore Concepts'), findsOneWidget);
    });

    testWidgets('renders knowledge overview', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allConceptsProvider.overrideWith((ref) async => testConcepts),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Your Knowledge'), findsOneWidget);
      expect(find.text('82%'), findsOneWidget);
      expect(find.text('Technology'), findsOneWidget);
    });
  });
}
