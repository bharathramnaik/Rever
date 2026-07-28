import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/features/home/presentation/screens/home_screen.dart';
import 'package:rever/src/core/providers/profile_provider.dart';
import 'package:rever/src/data/providers/feed_provider.dart';
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
            feedProvider.overrideWith((ref) async => []),
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
            feedProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Learner'), findsOneWidget);
    });

    testWidgets('renders feed section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.text('Learner'), findsOneWidget);
    });
  });
}
