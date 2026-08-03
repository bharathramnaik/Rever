import 'dart:convert';

import 'package:rever/src/core/services/llm_service.dart';

/// Signature for an LLM completion callable (same as content generator).
typedef GraphComplete = Future<LlmResult> Function(List<LlmMessage> messages);

/// An edge proposed by the LLM: connect the seed idea to candidate [targetIndex].
class GeneratedEdge {
  final int targetIndex;
  final String type;
  final double confidence;
  final String reason;

  const GeneratedEdge({
    required this.targetIndex,
    required this.type,
    required this.confidence,
    required this.reason,
  });
}

/// AI curator for the idea knowledge graph (flow.txt §5): given a seed idea
/// and candidate ideas, decides which are supports / contradicts /
/// prerequisite_of / related_to. Parsing is resilient to model noise
/// (code fences, prose around the JSON).
class RelationshipGenerator {
  final GraphComplete complete;

  RelationshipGenerator(this.complete);

  static const allowedTypes = {
    'supports',
    'contradicts',
    'prerequisite_of',
    'related_to',
    'example_of',
    'applies_to',
  };

  static const systemPrompt = '''
You are a knowledge-graph curator. Given a seed idea and a numbered list of
candidate ideas, find the strongest connections. Output a JSON array (no markdown
fences) of at most 4 objects: {"i": <candidate index>, "type": "<type>",
"confidence": 0.0-1.0, "reason": "<one short sentence>"}. Allowed types:
supports, contradicts, prerequisite_of, related_to, example_of, applies_to.
Skip candidates with no meaningful connection.
''';

  /// Generates edges from the seed idea text onto candidate ideas.
  /// Returns an empty list if the model is unavailable or output is unparseable.
  Future<List<GeneratedEdge>> generate(
    String seedText,
    List<String> candidateTexts,
  ) async {
    if (candidateTexts.isEmpty) return const [];
    final numbered = [
      for (var i = 0; i < candidateTexts.length; i++)
        '$i: ${candidateTexts[i]}',
    ].join('\n');

    final result = await complete([
      LlmMessage(role: LlmMessage.system, content: systemPrompt),
      LlmMessage(
        role: LlmMessage.user,
        content: 'Seed idea:\n$seedText\n\nCandidates:\n$numbered\n\nJSON:',
      ),
    ]);
    return switch (result) {
      LlmOk(text: final text) => _parse(text),
      LlmUnavailable() => const [],
    };
  }

  List<GeneratedEdge> _parse(String text) {
    List<dynamic> raw;
    try {
      raw = jsonDecode(text) as List;
    } catch (_) {
      final start = text.indexOf('[');
      final end = text.lastIndexOf(']');
      if (start == -1 || end == -1 || end <= start) return const [];
      try {
        raw = jsonDecode(text.substring(start, end + 1)) as List;
      } catch (_) {
        return const [];
      }
    }

    final edges = <GeneratedEdge>[];
    final seen = <int>{};
    for (final e in raw.take(6)) {
      if (e is! Map<String, dynamic>) continue;
      final index = (e['i'] as num?)?.toInt();
      if (index == null || !seen.add(index)) continue;
      final type = (e['type'] as String?)?.trim() ?? '';
      if (!allowedTypes.contains(type)) continue;
      edges.add(GeneratedEdge(
        targetIndex: index,
        type: type,
        confidence: (e['confidence'] as num?)?.toDouble() ?? 0.6,
        reason: (e['reason'] as String?)?.trim() ?? '',
      ));
    }
    return edges;
  }
}
