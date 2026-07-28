import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/features/explore/presentation/screens/explore_screen.dart';
import 'package:rever/src/data/providers/topic_providers.dart';
import '../helpers/test_data.dart';

void main() {
  group('ExploreScreen', () {
    testWidgets('renders search and topic grid', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            topicsProvider.overrideWith((ref) async => testTopics),
          ],
          child: const MaterialApp(home: ExploreScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('What do you want to learn?'), findsOneWidget);
      expect(find.text('Topics'), findsOneWidget);
      expect(find.text('Technology'), findsOneWidget);
      expect(find.text('Science'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            topicsProvider.overrideWith((ref) async => testTopics),
          ],
          child: const MaterialApp(home: ExploreScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows empty state when no topics', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            topicsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: ExploreScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Technology'), findsNothing);
    });
  });
}
