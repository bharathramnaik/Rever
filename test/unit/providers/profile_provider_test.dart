import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/profile_provider.dart';

void main() {
  group('ActiveProfileIdProvider', () {
    test('initial state is null', () {
      final container = ProviderContainer();
      final profileId = container.read(activeProfileIdProvider);
      expect(profileId, isNull);
    });

    test('select sets the profile id', () {
      final container = ProviderContainer();
      container.read(activeProfileIdProvider.notifier).select('profile-1');
      final profileId = container.read(activeProfileIdProvider);
      expect(profileId, 'profile-1');
    });

    test('select with null clears the profile id', () {
      final container = ProviderContainer();
      container.read(activeProfileIdProvider.notifier).select('profile-1');
      container.read(activeProfileIdProvider.notifier).select(null);
      final profileId = container.read(activeProfileIdProvider);
      expect(profileId, isNull);
    });
  });
}
