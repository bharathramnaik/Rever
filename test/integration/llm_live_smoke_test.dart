import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/core/services/llm_service.dart';

void main() {
  test('live NVIDIA chain: basic request -> non-empty response', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final config = container.read(llmProviderChainProvider);
    if (config.isEmpty) {
      markTestSkipped(
          'no LLM_API_KEY* dart-defines; run with '
          '--dart-define=LLM_API_KEY_NVIDIA[_NEMOTRON|_3]=...');
      return;
    }

    final service = LlmService(config);
    addTearDown(service.dispose);

    final result = await service.complete(const [
      LlmMessage(role: LlmMessage.user, content: 'Reply with exactly: OK'),
    ]);

    switch (result) {
      case LlmOk(:final text):
        expect(text.trim(), isNotEmpty);
        // ignore: avoid_print
        print('[live-llm] providers tried: '
            '${config.map((c) => c.provider).join(', ')}');
        // ignore: avoid_print
        print('[live-llm] response: $text');
      case LlmUnavailable(:final reason):
        fail('LlmUnavailable: $reason');
    }
  });
}
