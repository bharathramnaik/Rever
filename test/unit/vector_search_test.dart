import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rever/src/core/services/embedding_service.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:rever/src/data/providers/vector_search_provider.dart';

class FakeAdapter extends Mock implements HttpClientAdapter {}

EmbeddingClient clientWith(Map<String, Object> body, {int status = 200}) {
  final adapter = FakeAdapter();
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  dio.httpClientAdapter = adapter;
  registerFallbackValue(RequestOptions(path: '/embeddings'));
  registerFallbackValue(Stream<Uint8List>.empty());
  registerFallbackValue(Future.value());
  when(() => adapter.fetch(any(), any(), any())).thenAnswer((inv) async {
    return ResponseBody.fromString(
      json.encode(body),
      status,
      headers: {'content-type': ['application/json']},
    );
  });
  return EmbeddingClient(dio: dio, apiKey: 'fake', model: 'm');
}

void main() {
  group('cosineSimilarity', () {
    test('identical vectors -> 1', () {
      expect(
        EmbeddingClient.cosineSimilarity([1, 0, 0], [1, 0, 0]),
        closeTo(1, 0.0001),
      );
    });

    test('orthogonal -> 0', () {
      expect(
        EmbeddingClient.cosineSimilarity([1, 0], [0, 1]),
        closeTo(0, 0.0001),
      );
    });

    test('opposite -> -1', () {
      expect(
        EmbeddingClient.cosineSimilarity([1, 0], [-1, 0]),
        closeTo(-1, 0.0001),
      );
    });

    test('scaled vectors equal', () {
      final a = EmbeddingClient.cosineSimilarity([1, 2, 3], [2, 4, 6]);
      expect(a, closeTo(1, 0.0001));
    });

    test('mismatched/empty -> 0', () {
      expect(EmbeddingClient.cosineSimilarity([], [1]), 0);
      expect(EmbeddingClient.cosineSimilarity([1, 2], [1]), 0);
    });
  });

  group('EmbeddingClient.embed', () {
    test('parses OpenAI-compatible embedding response', () async {
      final client = clientWith({
        'data': [
          {'embedding': [0.1, 0.2, 0.3]}
        ]
      });
      final vector = await client.embed('habits');
      expect(vector, [0.1, 0.2, 0.3]);
    });

    test('non-200 -> null', () async {
      final client =
          clientWith({'error': {'message': 'bad key'}}, status: 401);
      expect(await client.embed('x'), isNull);
    });

    test('missing embedding -> null', () async {
      final client = clientWith({'data': [{}]});
      expect(await client.embed('x'), isNull);
    });
  });

  group('rerank + keyword fallback', () {
    test('rerank blends similarity with quality', () {
      expect(rerankScore(1.0, 1.0), closeTo(1.0, 0.0001));
      expect(rerankScore(0.5, 0.5), closeTo(0.5, 0.0001));
      expect(rerankScore(0.0, 1.0), closeTo(0.15, 0.0001));
    });

    test('keyword hits rank by term coverage', () {
      final cards = [
        IdeaCard(id: '1', takeaway: 'Habit stacking basics', body: 'x'),
        IdeaCard(id: '2', takeaway: 'Options pricing', body: 'finance'),
        IdeaCard(id: '3', takeaway: 'Stacking habits daily', body: 'y'),
      ];
      final hits = keywordHits('habit stacking', cards);
      expect(hits, hasLength(2));
      expect(hits.first.card.id, '1'); // both terms
      expect(hits.last.card.id, '3'); // one term
    });

    test('keyword empty query -> empty', () {
      expect(keywordHits('   ', [IdeaCard(id: '1', takeaway: 'a', body: 'b')]),
          isEmpty);
    });

    test('no matches -> empty', () {
      final cards = [IdeaCard(id: '1', takeaway: 'habits', body: 'b')];
      expect(keywordHits('quantum physics', cards), isEmpty);
    });
  });
}
