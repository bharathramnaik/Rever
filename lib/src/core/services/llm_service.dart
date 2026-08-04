import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Result of an LLM completion.
///
/// [LlmOk] carries generated text.
/// [LlmUnavailable] means the model was not reachable / not configured; the
/// reason is logged so callers can degrade to a local fallback.
sealed class LlmResult {
  const LlmResult();
}

final class LlmOk extends LlmResult {
  final String text;
  final int? inputTokens;
  final int? outputTokens;
  const LlmOk(this.text, {this.inputTokens, this.outputTokens});
}

final class LlmUnavailable extends LlmResult {
  final String reason;
  const LlmUnavailable(this.reason);
}

class LlmMessage {
  final String role;
  final String content;
  const LlmMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  static const system = 'system';
  static const user = 'user';
  static const assistant = 'assistant';
}

/// Configuration for a single OpenAI-compatible provider.
///
/// Keys are supplied via --dart-define only (never hardcoded). The chain is
/// built from whichever provider keys are present:
///
///   LLM_API_KEY_NVIDIA_NEMOTRON -> NVIDIA NIM (nemotron-3-ultra, with thinking)
///   LLM_API_KEY_NVIDIA_INKLING (+ LLM_MODEL_NVIDIA_INKLING) -> inkling slot
///   LLM_API_KEY_NVIDIA_3 (+ LLM_MODEL_NVIDIA_3) -> riva-translate slot
///
/// `--dart-define=LLM_PROVIDER=<nvidia-nemotron|nvidia-inkling|nvidia-riva>`
/// optionally reorders that provider to the front of the chain.
class LlmConfig {
  final String provider;
  final String baseUrl;
  final String model;
  final String apiKey;
  final int maxTokens;
  final double temperature;
  final double? topP;
  final int maxRetries;
  final int concurrency;
  final int timeoutSeconds;
  final Map<String, String> extraHeaders;
  final Map<String, dynamic> extraBody;

  const LlmConfig({
    required this.provider,
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    this.maxTokens = 2048,
    this.temperature = 0.7,
    this.topP,
    this.maxRetries = 2,
    this.concurrency = 8,
    this.timeoutSeconds = 30,
    this.extraHeaders = const {},
    this.extraBody = const {},
  });

  bool get isConfigured => apiKey.isNotEmpty;

  Map<String, dynamic> toBody(List<LlmMessage> messages) => {
        'model': model,
        'messages': messages.map((m) => m.toJson()).toList(),
        'max_tokens': maxTokens,
        'temperature': temperature,
        if (topP != null) 'top_p': topP,
        'stream': false,
        ...extraBody,
      };

  Map<String, String> headers() => {
        'Authorization': 'Bearer ${_normalizeKey(apiKey)}',
        'Content-Type': 'application/json',
        if (provider == 'openrouter') 'HTTP-Referer': 'https://rever.app',
        ...extraHeaders,
      };

  /// Keys are raw `nvapi-...` values; tolerate an accidental `Bearer ` prefix.
  static String _normalizeKey(String key) {
    final trimmed = key.trim();
    return trimmed.toLowerCase().startsWith('bearer ')
        ? trimmed.substring(7).trim()
        : trimmed;
  }
}

/// Ordered list of provider configs to try, first configured first.
final llmProviderChainProvider = Provider<List<LlmConfig>>((ref) {
  const nvNeoKey =
      String.fromEnvironment('LLM_API_KEY_NVIDIA_NEMOTRON', defaultValue: '');
  const nvInkKey = String.fromEnvironment(
      'LLM_API_KEY_NVIDIA_INKLING', defaultValue: '');
  const inkModel = String.fromEnvironment('LLM_MODEL_NVIDIA_INKLING',
      defaultValue: 'thinkingmachines/inkling');
  const nvRivaKey = String.fromEnvironment('LLM_API_KEY_NVIDIA_3', defaultValue: '');
  const rivaModel = String.fromEnvironment('LLM_MODEL_NVIDIA_3',
      defaultValue: 'nvidia/riva-translate-4b-instruct-v2');
  const prefer = String.fromEnvironment('LLM_PROVIDER', defaultValue: '');

  final chain = <LlmConfig>[
    if (nvNeoKey.isNotEmpty)
      LlmConfig(
        provider: 'nvidia-nemotron',
        baseUrl: 'https://integrate.api.nvidia.com/v1',
        model: 'nvidia/nemotron-3-ultra-550b-a55b',
        apiKey: nvNeoKey,
        maxTokens: 16384,
        temperature: 1.0,
        timeoutSeconds: 45,
        extraBody: const {
          'chat_template_kwargs': {'enable_thinking': true},
          'reasoning_budget': 16384,
        },
      ),
    if (nvInkKey.isNotEmpty)
      LlmConfig(
        provider: 'nvidia-inkling',
        baseUrl: 'https://integrate.api.nvidia.com/v1',
        model: inkModel,
        apiKey: nvInkKey,
        maxTokens: 8192,
        temperature: 1.0,
        topP: 0.95,
        timeoutSeconds: 45,
      ),
    if (nvRivaKey.isNotEmpty)
      LlmConfig(
        provider: 'nvidia-riva',
        baseUrl: 'https://integrate.api.nvidia.com/v1',
        model: rivaModel,
        apiKey: nvRivaKey,
        maxTokens: 2048,
        temperature: 0.2,
        timeoutSeconds: 45,
      ),
  ];

  // `--dart-define=LLM_PROVIDER=<x>` moves that provider to the front if present.
  final i = chain.indexWhere((c) => c.provider == prefer);
  if (i > 0) {
    final c = chain.removeAt(i);
    chain.insert(0, c);
  }
  return chain;
});

/// OpenAI-compatible LLM client with a **provider fallback chain**.
///
/// `complete` tries each configured provider in order; on timeout, network
/// error, 429 (exhausted), or an empty response it falls through to the next
/// provider. Per-provider timeouts guarantee one unresponsive provider cannot
/// block the call. Safe to call without any key: returns [LlmUnavailable].
class LlmService {
  final List<LlmConfig> config;
  final Dio _dio;
  final bool _ownsDio;
  int _inFlight = 0;
  final List<Completer<void>> _queue = [];

  LlmService(this.config, [Dio? dio])
      : _dio = dio ?? Dio(BaseOptions(validateStatus: (_) => true)),
        _ownsDio = dio == null;

  Future<void> dispose() {
    if (_ownsDio) _dio.close();
    return Future.value();
  }

  Future<LlmResult> complete(List<LlmMessage> messages) async {
    if (config.every((c) => !c.isConfigured)) {
      return const LlmUnavailable('No LLM_API_KEY* configured');
    }

    await _acquireSlot();
    try {
      final errors = <String>[];
      for (final c in config) {
        if (!c.isConfigured) continue;
        try {
          final result = await _doRequest(c, messages)
              .timeout(Duration(seconds: c.timeoutSeconds));
          if (result is LlmOk && result.text.trim().isNotEmpty) return result;
          if (result is LlmUnavailable) errors.add('${c.provider}: ${result.reason}');
        } on TimeoutException {
          errors.add('${c.provider}: timeout (${c.timeoutSeconds}s)');
        } catch (e) {
          errors.add('${c.provider}: $e');
        }
      }
      return LlmUnavailable(
          'All providers failed: ${errors.join(' | ')}');
    } finally {
      _releaseSlot();
    }
  }

  Future<void> _acquireSlot() {
    final cap = config.isNotEmpty ? config.first.concurrency : 8;
    if (_inFlight < cap) {
      _inFlight++;
      return Future.value();
    }
    final c = Completer<void>();
    _queue.add(c);
    return c.future.then((_) => _acquireSlot());
  }

  void _releaseSlot() {
    _inFlight--;
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      _inFlight++;
      next.complete();
    }
  }

  Future<LlmResult> _doRequest(LlmConfig c, List<LlmMessage> messages) async {
    for (var attempt = 0; attempt <= c.maxRetries; attempt++) {
      try {
        final resp = await _dio.post(
          '${c.baseUrl}/chat/completions',
          data: c.toBody(messages),
          options: Options(
            headers: c.headers(),
            sendTimeout: const Duration(seconds: 15),
            receiveTimeout: Duration(seconds: c.timeoutSeconds),
          ),
        );

        if (resp.statusCode == 429) {
          final retryAfter = _parseRetryAfter(resp);
          await _backoff(attempt, retryAfter);
          continue;
        }

        if (resp.statusCode == 200) {
          final data = resp.data as Map<String, dynamic>;
          final choices = (data['choices'] as List?) ?? [];
          String? text;
          if (choices.isNotEmpty) {
            final msg = choices.first as Map<String, dynamic>;
            final message = msg['message'] as Map<String, dynamic>?;
            text = message?['content'] as String?;
          }
          final usage = data['usage'] as Map<String, dynamic>?;
          if (text == null || text.isEmpty) {
            return const LlmUnavailable('Empty response from model');
          }
          return LlmOk(
            text,
            inputTokens: (usage?['prompt_tokens'] as num?)?.toInt(),
            outputTokens: (usage?['completion_tokens'] as num?)?.toInt(),
          );
        }

        // 401/402/empty per-provider -> let the chain try the next provider.
        final msg = ((resp.data as Map<String, dynamic>?)?['error']
                ?['message'])
            ?.toString() ??
            resp.statusMessage;
        debugPrint("[llm] ${c.provider} failed: ${resp.statusCode} $msg");
        if (resp.statusCode == 401) {
          return const LlmUnavailable('Invalid API key (401)');
        }
        if (resp.statusCode == 402) {
          return const LlmUnavailable('Insufficient balance (402)');
        }
        return LlmUnavailable('HTTP ${resp.statusCode}');
      } on DioException catch (e, st) {
        debugPrint('[llm] ${c.provider} network error: $e\n$st');
        if (attempt >= c.maxRetries) {
          return LlmUnavailable('Network error: ${e.message}');
        }
        await _backoff(attempt);
      }
    }
    return const LlmUnavailable('Max retries exceeded');
  }

  int _parseRetryAfter(Response resp) {
    final header = resp.headers['retry-after'];
    if (header == null || header.isEmpty) return 0;
    return int.tryParse(header.first) ?? 0;
  }

  Future<void> _backoff(int attempt, [int retryAfterSeconds = 0]) {
    final delay = retryAfterSeconds > 0
        ? Duration(seconds: retryAfterSeconds)
        : Duration(milliseconds: 500 * _pow(2, attempt).toInt());
    return Future.delayed(delay);
  }

  static num _pow(int base, int exp) {
    var result = 1;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}

final llmServiceProvider = Provider<LlmService>((ref) {
  final config = ref.watch(llmProviderChainProvider);
  final service = LlmService(config);
  ref.onDispose(service.dispose);
  return service;
});
