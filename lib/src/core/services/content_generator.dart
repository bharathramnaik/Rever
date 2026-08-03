import 'dart:convert';

import 'package:rever/src/core/services/llm_service.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:uuid/uuid.dart';

/// Signature for an LLM completion callable.
typedef LlmComplete = Future<LlmResult> Function(List<LlmMessage> messages);

/// Prompts + parsing for turning source text into structured [IdeaCard]s.
///
/// Output contract: the LLM is asked to return a JSON array of objects with
/// `headline`, `summary`, `takeaways` (list of 3-6 short strings), and
/// optional `examples`. We distill to short excerpts, keeping the surface
/// tight on copyright (original distillation, not verbatim copying).
class ContentGenerator {
  final LlmComplete complete;

  ContentGenerator(this.complete);

  static const systemPrompt = '''
You are a senior learning designer. Given a source text, produce a JSON array
of atomic idea cards. Each card has: headline (<=10 words), summary (1-2
sentences), takeaways (3-6 short bullet insights), examples (0-2 short
real-world examples), questions (2-3 short comprehension questions),
flashcards (2-3 objects with "front" and "back" for spaced repetition),
difficulty (one of: beginner, intermediate, advanced), tags (3-5 short
lowercase keywords), and language (ISO 639-1 code, default "en"). Keep
language vivid and jargon-free. Only emit valid JSON — no markdown code
fences.
''';

  Future<List<IdeaCard>> generate(String sourceText, {String? sourceTitle}) {
    final truncated = sourceText.length > 12000
        ? sourceText.substring(0, 12000)
        : sourceText;
    final context = sourceTitle != null
        ? 'Title: "$sourceTitle"\n\nText:\n$truncated\n\nJSON cards:'
        : 'Text:\n$truncated\n\nJSON cards:';

    return complete([
      LlmMessage(role: LlmMessage.system, content: systemPrompt),
      LlmMessage(role: LlmMessage.user, content: context),
    ]).then((result) => switch (result) {
          LlmOk(text: final text) => _parseCards(text),
          LlmUnavailable(reason: final reason) => throw _Unavailable(reason),
        });
  }

  List<IdeaCard> _parseCards(String text) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) {
        throw _Unavailable('Unparseable model output');
      }
      json = jsonDecode(text.substring(start, end + 1)) as Map<String, dynamic>;
    }

    final raw = (json['cards'] as List?) ?? json['ideas'] ?? [];
    final cards = <IdeaCard>[];
    for (final e in raw) {
      final m = e as Map<String, dynamic>;
      final headline = (m['headline'] as String?)?.trim();
      final summary = (m['summary'] as String?)?.trim();
      if (headline == null ||
          summary == null ||
          headline.isEmpty ||
          summary.isEmpty) {
        continue;
      }
      final takeaways = (m['takeaways'] as List?)
              ?.map((t) => (t as String).trim())
              .where((t) => t.isNotEmpty)
              .toList() ??
          const [];
      final examples = (m['examples'] as List?)
              ?.map((x) => (x as String).trim())
              .where((x) => x.isNotEmpty)
              .toList();

      final difficulty = switch (m['difficulty'] as String?) {
        'beginner' || 'intermediate' || 'advanced' => m['difficulty'] as String,
        _ => null,
      };
      final tags = (m['tags'] as List?)
              ?.map((t) => (t as String).trim().toLowerCase())
              .where((t) => t.isNotEmpty)
              .toList() ??
          const <String>[];
      final language = (m['language'] as String?)?.trim().toLowerCase() ?? 'en';
      var qualityScore =
          ((m['quality_score'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0).toDouble();

      final questions = (m['questions'] as List?)
              ?.map((q) => (q as String).trim())
              .where((q) => q.isNotEmpty)
              .toList() ??
          const <String>[];
      final flashcards = (m['flashcards'] as List?)
              ?.map((f) {
                final fm = f as Map<String, dynamic>;
                final front = (fm['front'] as String?)?.trim() ?? '';
                final back = (fm['back'] as String?)?.trim() ?? '';
                if (front.isEmpty || back.isEmpty) return null;
                return Flashcard(front: front, back: back);
              })
              .whereType<Flashcard>()
              .toList() ??
          const <Flashcard>[];

      // Quality gate (flow.txt §7): derive a score from structure when the
      // model did not supply one (presence of takeaways/questions/flashcards).
      if (qualityScore <= 0) {
        final structureScore = (takeaways.isNotEmpty ? 0.4 : 0) +
            (questions.isNotEmpty ? 0.2 : 0) +
            (flashcards.isNotEmpty ? 0.2 : 0) +
            (tags.isNotEmpty ? 0.1 : 0) +
            (difficulty != null ? 0.1 : 0);
        qualityScore = structureScore.clamp(0.0, 1.0).toDouble();
      }

      final body = StringBuffer(summary);
      if (takeaways.isNotEmpty) {
        body.write('\n\nKey takeaways:\n');
        for (final t in takeaways) {
          body.writeln('• $t');
        }
      }
      if (examples?.isNotEmpty == true) {
        body.write('\n\nExamples:\n');
        for (final x in examples!) {
          body.writeln('• $x');
        }
      }

      cards.add(IdeaCard(
        id: const Uuid().v4(),
        sourceId: null,
        conceptId: null,
        takeaway: headline,
        body: body.toString(),
        quote: null,
        audioUrl: null,
        likeCount: 0,
        mindBlownCount: 0,
        actionableCount: 0,
        difficulty: difficulty,
        qualityScore: qualityScore,
        language: language,
        tags: tags,
        takeaways: takeaways,
        examples: examples ?? const [],
        questions: questions,
        flashcards: flashcards,
      ));
    }
    if (cards.isEmpty) throw const _Unavailable('Model returned no cards');
    return cards;
  }
}

class _Unavailable implements Exception {
  final String message;
  const _Unavailable(this.message);
  @override
  String toString() => 'ContentGenerationUnavailable: $message';
}

