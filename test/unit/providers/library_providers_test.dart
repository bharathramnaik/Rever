import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/providers/library_providers.dart';
import '../../helpers/test_data.dart';

void main() {
  group('LibraryProviders', () {
    test('savedObjectsProvider returns test objects', () async {
      final container = ProviderContainer(
        overrides: [
          savedObjectsProvider
              .overrideWith((ref, profileId) async => testLearningObjects),
        ],
      );
      final objects = await container.read(
        savedObjectsProvider('profile-id').future,
      );
      expect(objects, hasLength(2));
      expect(objects[0].objectType, 'card');
      expect(objects[1].objectType, 'quiz');
    });

    test('savedObjectsProvider handles empty list', () async {
      final container = ProviderContainer(
        overrides: [
          savedObjectsProvider
              .overrideWith((ref, profileId) async => []),
        ],
      );
      final objects = await container.read(
        savedObjectsProvider('profile-id').future,
      );
      expect(objects, isEmpty);
    });
  });
}
