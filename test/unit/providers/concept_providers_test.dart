import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/providers/concept_providers.dart';
import '../../helpers/test_data.dart';

void main() {
  group('ConceptProviders', () {
    test('conceptBySlugProvider returns test concept', () async {
      final container = ProviderContainer(
        overrides: [
          conceptBySlugProvider
              .overrideWith((ref, slug) async => testConcept),
        ],
      );
      final concept = await container.read(
        conceptBySlugProvider('how-transformers-work').future,
      );
      expect(concept, isNotNull);
      expect(concept!.title, 'How Transformers Work');
    });

    test('conceptBySlugProvider returns null for unknown slug', () async {
      final container = ProviderContainer(
        overrides: [
          conceptBySlugProvider.overrideWith((ref, slug) async => null),
        ],
      );
      final concept = await container.read(
        conceptBySlugProvider('unknown').future,
      );
      expect(concept, isNull);
    });

    test('conceptsByTopicProvider returns test concepts', () async {
      final container = ProviderContainer(
        overrides: [
          conceptsByTopicProvider
              .overrideWith((ref, topicId) async => testConcepts),
        ],
      );
      final concepts = await container.read(
        conceptsByTopicProvider('topic-id').future,
      );
      expect(concepts, hasLength(3));
    });
  });
}
