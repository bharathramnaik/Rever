import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/core/services/content_generator.dart';
import 'package:rever/src/core/services/duplicate_detector.dart';
import 'package:rever/src/core/services/llm_service.dart';
import 'package:rever/src/data/models/idea_card_model.dart';

void main() {
  group('multi-asset generation (flow.txt §7)', () {
    test('parses questions + flashcards + quality gate fallback', () async {
      final gen = ContentGenerator((_) async => LlmOk('''
{"cards": [
  {
    "headline": "Habit stacking",
    "summary": "Pair a new habit with an existing one.",
    "takeaways": ["Attach new routines", "Use cues"],
    "examples": ["After coffee, write"],
    "questions": ["What makes habit stacking effective?"],
    "flashcards": [
      {"front": "Habit stacking", "back": "Pair new with existing"},
      {"front": "Cue", "back": "Trigger for the routine"}
    ],
    "difficulty": "beginner",
    "tags": ["habits"]
  }
]}
'''));
      final cards = await gen.generate('src');
      expect(cards, hasLength(1));
      final card = cards.first;
      expect(card.takeaways, ['Attach new routines', 'Use cues']);
      expect(card.examples, ['After coffee, write']);
      expect(card.questions, ['What makes habit stacking effective?']);
      expect(card.flashcards, hasLength(2));
      expect(card.flashcards.first.front, 'Habit stacking');
      expect(card.flashcards.first.back, 'Pair new with existing');
      // no model quality_score -> structural gate kicks in
      expect(card.qualityScore, greaterThan(0));
    });

    test('incomplete flashcards are dropped', () async {
      final gen = ContentGenerator((_) async => LlmOk('''
{"cards": [{
  "headline": "X", "summary": "Y",
  "flashcards": [{"front": "q"}, {"front": "a", "back": "b"}]
}]}
'''));
      final cards = await gen.generate('src');
      expect(cards.first.flashcards, hasLength(1));
      expect(cards.first.flashcards.first.front, 'a');
    });

    test('model-provided quality_score is respected', () async {
      final gen = ContentGenerator((_) async => LlmOk(
          '{"cards": [{"headline": "X", "summary": "Y", "quality_score": 0.9}]}'));
      final cards = await gen.generate('src');
      expect(cards.first.qualityScore, closeTo(0.9, 0.001));
    });
  });

  group('DuplicateDetector', () {
    test('identical text is a duplicate', () {
      const d = DuplicateDetector();
      expect(d.isDuplicate('Atomic habits change your identity',
          ['Atomic habits change your identity']), isTrue);
    });

    test('near-identical (case/punctuation drift) is a duplicate', () {
      const d = DuplicateDetector();
      expect(
        d.isDuplicate('Atomic habits shape identity daily',
            ['atomic habits shape identity daily.']),
        isTrue,
      );
    });

    test('different topic is not a duplicate', () {
      const d = DuplicateDetector();
      expect(
        d.isDuplicate('The stock market pricing of options',
            ['Habit formation and identity change']),
        isFalse,
      );
    });

    test('empty existing list -> not a duplicate', () {
      const d = DuplicateDetector();
      expect(d.isDuplicate('anything', []), isFalse);
    });

    test('similarity symmetric', () {
      expect(
        DuplicateDetector.similarity('a b c d', 'c d e f'),
        DuplicateDetector.similarity('c d e f', 'a b c d'),
      );
    });
  });

  group('IdeaCard assets roundtrip', () {
    test('fromJson/toJson preserves assets', () {
      final card = IdeaCard.fromJson({
        'id': 'c1',
        'takeaway': 't',
        'body': 'b',
        'takeaways': ['t1'],
        'examples': ['e1'],
        'questions': ['q1'],
        'flashcards': [
          {'front': 'f', 'back': 'b'}
        ],
      });
      expect(card.takeaways, ['t1']);
      expect(card.questions, ['q1']);
      final json = card.toJson();
      expect(json['flashcards'], hasLength(1));
      expect((json['flashcards'] as List).first['front'], 'f');
    });
  });
}
