import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/features/concept/presentation/screens/concept_screen.dart';
import 'package:rever/src/data/providers/concept_providers.dart';
import '../helpers/test_data.dart';

void main() {
  group('ConceptScreen', () {
    testWidgets('renders concept title and summary', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conceptBySlugProvider
                .overrideWith((ref, slug) async => testConcept),
            learningObjectsProvider
                .overrideWith((ref, conceptId) async => testLearningObjects),
          ],
          child: const MaterialApp(
            home: ConceptScreen(conceptId: 'how-transformers-work'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('How Transformers Work'), findsAtLeast(1));
      expect(
        find.text(
            'Transformers are a neural network architecture that revolutionized AI.'),
        findsOneWidget,
      );
    });

    testWidgets('renders card at Glance depth and quiz at Master depth',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conceptBySlugProvider
                .overrideWith((ref, slug) async => testConcept),
            learningObjectsProvider
                .overrideWith((ref, conceptId) async => testLearningObjects),
          ],
          child: const MaterialApp(
            home: ConceptScreen(conceptId: 'how-transformers-work'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Transformer Architecture'), findsOneWidget);

      await tester.tap(find.text('Master'));
      await tester.pumpAndSettle();

      expect(find.text('Quiz'), findsOneWidget);
    });

    testWidgets('shows difficulty chip', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conceptBySlugProvider
                .overrideWith((ref, slug) async => testConcept),
            learningObjectsProvider
                .overrideWith((ref, conceptId) async => testLearningObjects),
          ],
          child: const MaterialApp(
            home: ConceptScreen(conceptId: 'how-transformers-work'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('shows empty state for current depth', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conceptBySlugProvider
                .overrideWith((ref, slug) async => testConcept),
            learningObjectsProvider
                .overrideWith((ref, conceptId) async => []),
          ],
          child: const MaterialApp(
            home: ConceptScreen(conceptId: 'how-transformers-work'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No glance content yet'), findsOneWidget);
    });

    testWidgets('shows not found when concept is null', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conceptBySlugProvider
                .overrideWith((ref, slug) async => null),
            learningObjectsProvider
                .overrideWith((ref, conceptId) async => []),
          ],
          child: const MaterialApp(
            home: ConceptScreen(conceptId: 'unknown-concept'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Concept not found'), findsOneWidget);
    });
  });
}
