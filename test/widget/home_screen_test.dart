import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/features/home/presentation/screens/home_screen.dart';
import 'package:rever/src/data/providers/quote_provider.dart';
import 'package:rever/src/data/services/external_content_service.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders greeting with default name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomQuoteProvider.overrideWith((ref) async => null),
            trendingContentProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Learner'), findsOneWidget);
    });

    testWidgets('renders quick actions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomQuoteProvider.overrideWith((ref) async => null),
            trendingContentProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
    });
  });
}
