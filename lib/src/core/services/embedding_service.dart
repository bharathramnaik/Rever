import 'dart:math' as math;

import 'package:dio/dio.dart';

/// NVIDIA NIM embedding client (OpenAI-compatible `/v1/embeddings`).
///
/// Key comes from the chat chain's dart-defines (first available of
/// `LLM_API_KEY_NVIDIA_3` / `LLM_API_KEY_NVIDIA_INKLING` /
/// `LLM_API_KEY_NVIDIA_NEMOTRON`; model overridable with `LLM_EMBED_MODEL`).
/// No key -> null client, and callers degrade to keyword search
/// (flow.txt §4 fallback).
class EmbeddingClient {
  final Dio _dio;
  final String apiKey;
  final String model;
  final String baseUrl;

  EmbeddingClient({
    required Dio dio,
    required this.apiKey,
    required this.model,
    this.baseUrl = 'https://integrate.api.nvidia.com/v1',
  }) : _dio = dio;

  static const defaultModel = 'nvidia/llama-3.2-nv-embedqa-1b-v2';

  /// Builds a client from dart-define, or null when no NIM key is configured.
  static EmbeddingClient? fromEnvironment() {
    const candidates = [
      String.fromEnvironment('LLM_API_KEY_NVIDIA_3', defaultValue: ''),
      String.fromEnvironment('LLM_API_KEY_NVIDIA_INKLING', defaultValue: ''),
      String.fromEnvironment('LLM_API_KEY_NVIDIA_NEMOTRON', defaultValue: ''),
    ];
    final key = candidates.where((k) => k.isNotEmpty).firstOrNull;
    if (key == null) return null;
    const model = String.fromEnvironment(
      'LLM_EMBED_MODEL',
      defaultValue: defaultModel,
    );
    return EmbeddingClient(dio: Dio(), apiKey: key, model: model);
  }

  Future<List<double>?> embed(String text) async {
    final resp = await _dio.post(
      '$baseUrl/embeddings',
      data: {'model': model, 'input': text},
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    if (resp.statusCode != 200) return null;
    final data = resp.data as Map<String, dynamic>?;
    final first = (data?['data'] as List?)
        ?.cast<Map<String, dynamic>>()
        .firstOrNull;
    if (first == null) return null;
    return (first['embedding'] as List?)
        ?.cast<num>()
        .map((v) => v.toDouble())
        .toList();
  }

  /// Cosine similarity, 1.0 = identical direction, 0 = orthogonal.
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0;
    var dot = 0.0, na = 0.0, nb = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na == 0 || nb == 0) return 0;
    return dot / (math.sqrt(na) * math.sqrt(nb));
  }
}
