import 'package:flutter_test/flutter_test.dart';
import 'package:rever/src/data/models/signal_model.dart';
import 'package:rever/src/data/repositories/signal_repository.dart';

class FakeSink implements SignalSink {
  final List<SignalModel> recorded = [];

  @override
  Future<void> record(SignalModel signal) async {
    recorded.add(signal);
  }
}

void main() {
  test('SignalModel roundtrip', () {
    final model = SignalModel.fromJson({
      'id': 's1',
      'profile_id': 'p1',
      'idea_card_id': 'c1',
      'signal_type': 'liked',
      'payload': {'source_id': 'book-1'},
      'created_at': '2026-01-01T00:00:00Z',
    });
    expect(model.signalType, 'liked');
    expect(model.payload['source_id'], 'book-1');
    expect(model.toJson()['signal_type'], 'liked');
    expect(model.toJson(), isNot(contains('id')));
  });

  test('dev mode (disabled) -> sink never called', () async {
    final sink = FakeSink();
    final recorder = SignalRecorder(sink: sink, enabled: false);
    await recorder.record('opened', ideaCardId: 'c1');
    expect(sink.recorded, isEmpty);
  });

  test('invalid signal type rejected', () async {
    final sink = FakeSink();
    final recorder = SignalRecorder(
      sink: sink,
      enabled: true,
      profileIdOf: () => 'p1',
    );
    await recorder.record('hovered');
    expect(sink.recorded, isEmpty);
  });

  test('valid signal recorded with profile id', () async {
    final sink = FakeSink();
    final recorder = SignalRecorder(
      sink: sink,
      enabled: true,
      profileIdOf: () => 'p1',
    );
    await recorder.record('dwelled',
        ideaCardId: 'c1', payload: const {'source_id': 'book-1'});
    expect(sink.recorded, hasLength(1));
    final s = sink.recorded.first;
    expect(s.profileId, 'p1');
    expect(s.ideaCardId, 'c1');
    expect(s.signalType, 'dwelled');
    expect(s.payload['source_id'], 'book-1');
  });

  test('no profile selected -> not recorded', () async {
    final sink = FakeSink();
    final recorder = SignalRecorder(
      sink: sink,
      enabled: true,
      profileIdOf: () => null,
    );
    await recorder.record('saved');
    expect(sink.recorded, isEmpty);
  });
}
