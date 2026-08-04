import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rever/src/core/services/llm_service.dart';

/// Fake Dio transport so the LlmService fallback chain can be exercised
/// without real network or real API keys (keys are confidential / not tested).
class FakeAdapter extends Mock implements HttpClientAdapter {}

class _Resp {
  final int status;
  final Map<String, dynamic> body;
  _Resp(this.status, this.body);
}

/// Build a fake Dio whose adapter returns scripted [ResponseBody]s keyed by
/// the **model name** in the request body (both NVIDIA configs share the same
/// host, so the model is the only discriminator).
Dio _fakeDio(Map<String, _Resp> byModel) {
  final adapter = FakeAdapter();
  final dio = Dio(BaseOptions(validateStatus: (_) => true));
  dio.httpClientAdapter = adapter;

  registerFallbackValue(RequestOptions(path: '/chat/completions'));
  registerFallbackValue(Stream<Uint8List>.empty());
  registerFallbackValue(Future.value());

  when(() => adapter.fetch(any(), any(), any())).thenAnswer((inv) async {
    final opts = inv.positionalArguments.first as RequestOptions;
    final model =
        (opts.data as Map<String, dynamic>?)?['model'] as String? ?? '';
    final resp = byModel[model] ?? byModel.values.first;
    return ResponseBody.fromString(
      json.encode(resp.body),
      resp.status,
      headers: {
        'content-type': ['application/json'],
      },
    );
  });
  return dio;
}

const _kimi = 'moonshotai/kimi-k2.6';
const _nemotron = 'nvidia/nemotron-3-ultra-550b-a55b';

void main() {
  test('no providers configured -> LlmUnavailable', () async {
    final svc = LlmService(const []);
    final res = await svc.complete([]);
    expect(res, isA<LlmUnavailable>());
  });

  test(
    'single provider 200 -> LlmOk parses text + token usage + reasoning',
    () async {
      final dio = _fakeDio({
        _kimi: _Resp(200, {
          'choices': [
            {
              'message': {
                'content': 'hi there',
                'reasoning': 'thinking step 1',
              },
            },
          ],
          'usage': {'prompt_tokens': 3, 'completion_tokens': 2},
        }),
      });
      final cfg = LlmConfig(
        provider: 'nvidia',
        baseUrl: 'https://integrate.api.nvidia.com/v1',
        model: _kimi,
        apiKey: 'fake',
      );
      final svc = LlmService([cfg], dio);
      final res = await svc.complete([LlmMessage(role: 'user', content: 'hi')]);
      expect(res, isA<LlmOk>());
      if (res case LlmOk(
        text: final t,
        inputTokens: final it,
        outputTokens: final ot,
        reasoning: final r,
      )) {
        expect(t, 'hi there');
        expect(it, 3);
        expect(ot, 2);
        expect(r, 'thinking step 1');
      }
    },
  );

  test('401 on provider -> LlmUnavailable (no retry loop)', () async {
    final dio = _fakeDio({
      _kimi: _Resp(401, {
        'error': {'message': 'unauthorized'},
      }),
    });
    final cfg = LlmConfig(
      provider: 'nvidia',
      baseUrl: 'https://integrate.api.nvidia.com/v1',
      model: _kimi,
      apiKey: 'fake',
      maxRetries: 1,
    );
    final svc = LlmService([cfg], dio);
    final res = await svc.complete([LlmMessage(role: 'user', content: 'hi')]);
    expect(res, isA<LlmUnavailable>());
    expect((res as LlmUnavailable).reason, contains('401'));
  });

  test('fallback chain: kimi (401) -> nemotron (200)', () async {
    final dio = _fakeDio({
      _kimi: _Resp(401, {
        'error': {'message': 'bad key'},
      }),
      _nemotron: _Resp(200, {
        'choices': [
          {
            'message': {'content': 'from nemotron'},
          },
        ],
      }),
    });
    final chain = [
      LlmConfig(
        provider: 'nvidia',
        baseUrl: 'https://integrate.api.nvidia.com/v1',
        model: _kimi,
        apiKey: 'fake-nv',
      ),
      LlmConfig(
        provider: 'nvidia-nemotron',
        baseUrl: 'https://integrate.api.nvidia.com/v1',
        model: _nemotron,
        apiKey: 'fake-nv-neo',
      ),
    ];
    final svc = LlmService(chain, dio);
    final res = await svc.complete([LlmMessage(role: 'user', content: 'hi')]);
    expect(res, isA<LlmOk>());
    if (res case LlmOk(text: final t)) {
      expect(t, 'from nemotron');
    }
  });

  test('all providers fail -> LlmUnavailable aggregated', () async {
    final dio = _fakeDio({
      _kimi: _Resp(402, {
        'error': {'message': 'billing'},
      }),
      _nemotron: _Resp(200, {'choices': []}), // empty -> unavailable, try next
    });
    final chain = [
      LlmConfig(
        provider: 'nvidia',
        baseUrl: 'https://integrate.api.nvidia.com/v1',
        model: _kimi,
        apiKey: 'fake-nv',
        maxRetries: 0,
      ),
      LlmConfig(
        provider: 'nvidia-nemotron',
        baseUrl: 'https://integrate.api.nvidia.com/v1',
        model: _nemotron,
        apiKey: 'fake-nv-neo',
        maxRetries: 0,
      ),
    ];
    final svc = LlmService(chain, dio);
    final res = await svc.complete([LlmMessage(role: 'user', content: 'hi')]);
    expect(res, isA<LlmUnavailable>());
    expect((res as LlmUnavailable).reason, contains('All providers failed'));
  });

  test('normalizes Bearer prefix and emits top_p', () async {
    final adapter = FakeAdapter();
    final dio = Dio(BaseOptions(validateStatus: (_) => true));
    dio.httpClientAdapter = adapter;

    registerFallbackValue(RequestOptions(path: '/chat/completions'));
    registerFallbackValue(Stream<Uint8List>.empty());
    registerFallbackValue(Future.value());

    RequestOptions? captured;
    when(() => adapter.fetch(any(), any(), any())).thenAnswer((inv) async {
      captured = inv.positionalArguments.first as RequestOptions;
      return ResponseBody.fromString(
        json.encode({
          'choices': [
            {
              'message': {'content': 'ok'},
            },
          ],
        }),
        200,
        headers: {
          'content-type': ['application/json'],
        },
      );
    });

    final cfg = LlmConfig(
      provider: 'nvidia',
      baseUrl: 'https://integrate.api.nvidia.com/v1',
      model: _kimi,
      apiKey: 'Bearer nvapi-fake-key',
      topP: 0.95,
    );
    final svc = LlmService([cfg], dio);
    final res = await svc.complete([LlmMessage(role: 'user', content: 'hi')]);
    expect(res, isA<LlmOk>());
    expect(captured!.headers['Authorization'], 'Bearer nvapi-fake-key');
    final body = captured!.data as Map<String, dynamic>;
    expect(body['top_p'], 0.95);
    expect(body['stream'], false);
  });
}
