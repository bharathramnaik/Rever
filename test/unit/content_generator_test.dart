import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/core/services/content_generator.dart';
import 'package:rever/src/core/services/llm_service.dart';

void main() {
  ContentGenerator genWith(String output) =>
      ContentGenerator((_) async => LlmOk(output));

  test('parses cards with difficulty, tags, language, quality', () async {
    final gen = genWith('''
{"cards": [
  {
    "headline": "Habit stacking",
    "summary": "Pair a new habit with an existing one.",
    "takeaways": ["Attach new routines", "Use cues"],
    "examples": ["After coffee, write"],
    "difficulty": "beginner",
    "tags": ["habits", "routines", "behavior"],
    "language": "en",
    "quality_score": 0.82
  }
]}
''');
    final cards = await gen.generate('source text');
    expect(cards, hasLength(1));
    final card = cards.first;
    expect(card.difficulty, 'beginner');
    expect(card.language, 'en');
    expect(card.qualityScore, closeTo(0.82, 0.001));
    expect(card.tags, ['habits', 'routines', 'behavior']);
    expect(card.status, 'published');
  });

  test('invalid difficulty -> null, missing fields -> defaults', () async {
    final gen = genWith(
      '{"cards": [{"headline": "X", "summary": "Y", "difficulty": "expert"}]}',
    );
    final cards = await gen.generate('src');
    final card = cards.first;
    expect(card.difficulty, isNull);
    expect(card.language, 'en');
    expect(card.qualityScore, 0);
    expect(card.tags, isEmpty);
  });

  test('strips markdown fences and surrounding prose', () async {
    final gen = genWith(
      'Here you go:\n```json\n{"ideas": [{"headline": "A", "summary": "B", "tags": ["x"]}]}\n```',
    );
    final cards = await gen.generate('src');
    expect(cards, hasLength(1));
    expect(cards.first.takeaway, 'A');
  });

  test('cards missing headline or summary are skipped -> throws', () async {
    final gen = genWith(
      '{"cards": [{"headline": "", "summary": "B"}, {"headline": "C"}]}',
    );
    expect(() => gen.generate('src'), throwsA(isA<Exception>()));
  });

  test('unparseable output -> throws ContentGenerationUnavailable', () async {
    final gen = genWith('sorry, no JSON here');
    expect(() => gen.generate('src'), throwsA(isA<Exception>()));
  });

  test('model unavailable -> throws, no cards', () async {
    final gen = ContentGenerator((_) async => const LlmUnavailable('no key'));
    expect(() => gen.generate('src'), throwsA(isA<Exception>()));
  });
}
