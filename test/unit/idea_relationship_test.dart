import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/core/services/llm_service.dart';
import 'package:rever/src/core/services/relationship_generator.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:rever/src/data/models/idea_relationship_model.dart';
import 'package:rever/src/data/providers/idea_relationship_providers.dart';

void main() {
  group('IdeaRelationshipModel', () {
    test('fromJson/toJson roundtrip', () {
      final model = IdeaRelationshipModel.fromJson({
        'id': 'a',
        'source_idea_id': 's',
        'target_idea_id': 't',
        'relationship_type': 'contradicts',
        'confidence': 0.8,
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(model.typeLabel, 'Contradicts');
      expect(model.confidence, 0.8);
      expect(model.toJson()['relationship_type'], 'contradicts');
      expect(model.toJson()['confidence'], 0.8);
    });

    test('unknown type falls back to raw string', () {
      const model = IdeaRelationshipModel(
        id: 'a',
        sourceIdeaId: 's',
        targetIdeaId: 't',
        relationshipType: 'weird_edge',
      );
      expect(model.typeLabel, 'weird_edge');
    });
  });

  group('RelationshipGenerator parsing', () {
    Future<List<GeneratedEdge>> genWith(String output) {
      final gen = RelationshipGenerator((_) async => LlmOk(output));
      return gen.generate('seed', ['one', 'two', 'three']);
    }

    test('parses clean JSON array', () async {
      final edges = await genWith(
        '[{"i": 1, "type": "contradicts", "confidence": 0.9, "reason": "x"},'
        ' {"i": 2, "type": "supports", "confidence": 0.7, "reason": "y"}]',
      );
      expect(edges, hasLength(2));
      expect(edges.first.targetIndex, 1);
      expect(edges.first.type, 'contradicts');
      expect(edges.first.confidence, 0.9);
    });

    test('strips markdown fences + prose around JSON', () async {
      final edges = await genWith(
        '```json\n'
        '[{"i": 0, "type": "related_to", "confidence": 0.6, "reason": "r"}]\n'
        '```',
      );
      expect(edges, hasLength(1));
      expect(edges.first.type, 'related_to');
    });

    test('rejects disallowed types', () async {
      final edges = await genWith(
        '[{"i": 0, "type": "parent_of", "confidence": 0.9, "reason": "x"}]',
      );
      expect(edges, isEmpty);
    });

    test('dedupes duplicate candidate indexes', () async {
      final edges = await genWith(
        '[{"i": 1, "type": "supports"}, {"i": 1, "type": "contradicts"}]',
      );
      expect(edges, hasLength(1));
    });

    test('model unavailable -> empty list (degrade gracefully)', () async {
      final gen = RelationshipGenerator((_) async => const LlmUnavailable('no key'));
      expect(await gen.generate('seed', ['a']), isEmpty);
    });

    test('no candidates -> no call, empty list', () async {
      final gen = RelationshipGenerator((_) async => LlmOk('[]'));
      expect(await gen.generate('seed', []), isEmpty);
    });
  });

  group('deriveRelatedIdeas (dev heuristic)', () {
    final cards = [
      IdeaCard(id: '1', sourceId: 'book-a', takeaway: 'one', body: 'x'),
      IdeaCard(id: '2', sourceId: 'book-a', takeaway: 'two', body: 'y'),
      IdeaCard(id: '3', sourceId: 'book-b', takeaway: 'three', body: 'z'),
      IdeaCard(id: '4', conceptId: 'concept-1', takeaway: 'four', body: 'w'),
    ];

    test('same source -> related_to for every matching card', () {
      final related = deriveRelatedIdeas(const RelatedSeed(sourceId: 'book-a'), cards);
      expect(related, hasLength(2));
      expect(related.every((r) => r.relationshipType == 'related_to'), isTrue);
      expect(related.map((r) => r.card.id).toSet(), {'1', '2'});
    });

    test('same concept -> related_to', () {
      final related = deriveRelatedIdeas(
          const RelatedSeed(conceptId: 'concept-1'), cards);
      expect(related, hasLength(1));
      expect(related.first.card.id, '4');
    });

    test('excludes the seed card itself', () {
      final related = deriveRelatedIdeas(
          const RelatedSeed(sourceId: 'book-a', cardId: '2'), cards);
      expect(related, hasLength(1));
      expect(related.first.card.id, '1');
    });

    test('no match -> empty', () {
      expect(
        deriveRelatedIdeas(const RelatedSeed(sourceId: 'book-z'), cards),
        isEmpty,
      );
    });
  });
}
