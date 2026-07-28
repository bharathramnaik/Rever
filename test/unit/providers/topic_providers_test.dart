import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/providers/topic_providers.dart';
import '../../helpers/test_data.dart';

void main() {
  group('TopicProviders', () {
    test('topicsProvider returns test topics', () async {
      final container = ProviderContainer(
        overrides: [
          topicsProvider.overrideWith((ref) async => testTopics),
        ],
      );
      final topics = await container.read(topicsProvider.future);
      expect(topics, hasLength(3));
      expect(topics[0].name, 'Technology');
      expect(topics[0].slug, 'technology');
    });

    test('topicsProvider handles empty list', () async {
      final container = ProviderContainer(
        overrides: [
          topicsProvider.overrideWith((ref) async => []),
        ],
      );
      final topics = await container.read(topicsProvider.future);
      expect(topics, isEmpty);
    });
  });
}
