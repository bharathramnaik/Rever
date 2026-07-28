import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/providers/streak_providers.dart';
import '../../helpers/test_data.dart';

void main() {
  group('StreakProviders', () {
    test('streakProvider returns test streak', () async {
      final container = ProviderContainer(
        overrides: [
          streakProvider
              .overrideWith((ref, profileId) async => testStreak),
        ],
      );
      final streak = await container.read(
        streakProvider('profile-id').future,
      );
      expect(streak, isNotNull);
      expect(streak!.currentStreak, 5);
      expect(streak.longestStreak, 10);
    });

    test('streakProvider returns null for new profile', () async {
      final container = ProviderContainer(
        overrides: [
          streakProvider.overrideWith((ref, profileId) async => null),
        ],
      );
      final streak = await container.read(
        streakProvider('new-profile').future,
      );
      expect(streak, isNull);
    });
  });
}
