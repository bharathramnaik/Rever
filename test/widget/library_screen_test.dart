import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/features/library/presentation/screens/library_screen.dart';
import 'package:rever/src/data/providers/library_providers.dart';
import '../helpers/test_data.dart';

void main() {
  group('LibraryScreen', () {
    testWidgets('renders library with saved objects', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savedObjectsProvider
                .overrideWith((ref, profileId) async => testLearningObjects),
          ],
          child: const MaterialApp(home: LibraryScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your Library'), findsOneWidget);
      expect(find.text('Transformer Architecture'), findsOneWidget);
      expect(find.text('Transformer Quick Quiz'), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            savedObjectsProvider
                .overrideWith((ref, profileId) async => []),
          ],
          child: const MaterialApp(home: LibraryScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Start learning to build your library'), findsOneWidget);
    });
  });
}
