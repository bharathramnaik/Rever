import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';

void main() {
  group('AuthProvider', () {
    test('user is null when not authenticated', () {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => const Stream.empty()),
        ],
      );
      final user = container.read(currentUserProvider);
      expect(user, isNull);
    });

    test('isAuthenticated is false when no user', () {
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => const Stream.empty()),
        ],
      );
      final isAuth = container.read(isAuthenticatedProvider);
      expect(isAuth, false);
    });
  });
}
