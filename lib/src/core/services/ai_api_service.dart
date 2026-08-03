import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment.dart';

/// Message tuple used for the chat request's conversation history.
class AiHistoryEntry {
  final String role;
  final String content;

  const AiHistoryEntry({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Chat response from the Rever AI backend.
class AiChatResult {
  final String reply;
  final List<GroundingSource> groundingSources;

  const AiChatResult({
    required this.reply,
    this.groundingSources = const [],
  });

  bool get hasGrounding => groundingSources.isNotEmpty;
}

class GroundingSource {
  final String title;
  final String url;
  final String snippet;

  const GroundingSource({
    required this.title,
    this.url = '',
    this.snippet = '',
  });

  factory GroundingSource.fromJson(Map<String, dynamic> json) =>
      GroundingSource(
        title: json['title'] as String? ?? '',
        url: json['url'] as String? ?? '',
        snippet: json['snippet'] as String? ?? '',
      );
}

/// Thin client for the Rever AI FastAPI service.
///
/// Purely additive: if the backend is unreachable, callers fall back to
/// local placeholder content, so the UI never blocks in dev.
class AiApiService {
  final Dio _dio;

  AiApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppEnvironment.aiBaseUrl,
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 30),
            ));

  /// Sends a chat message to the AI Tutor endpoint.
  ///
  /// Throws on network/HTTP failure — callers should catch and fall back.
  Future<AiChatResult> chat({
    required String message,
    String mode = 'explain',
    String? conceptId,
    List<AiHistoryEntry> history = const [],
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/ai/chat',
      data: {
        'message': message,
        'mode': mode,
        'concept_id': ?conceptId,
        'conversation_history': history.map((e) => e.toJson()).toList(),
      },
    );
    final data = response.data ?? const <String, dynamic>{};
    final sources = (data['grounding_sources'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(GroundingSource.fromJson)
        .toList();
    return AiChatResult(
      reply: data['reply'] as String? ?? '',
      groundingSources: sources,
    );
  }
}

final aiApiServiceProvider = Provider<AiApiService>((ref) {
  return AiApiService();
});