import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rever/src/data/models/signal_model.dart';

/// Where signals get persisted (Supabase in production).
abstract class SignalSink {
  Future<void> record(SignalModel signal);
}

class SignalRepository implements SignalSink {
  final SupabaseClient _client;
  SignalRepository(this._client);

  @override
  Future<void> record(SignalModel signal) async {
    await _client.from('signals').insert(signal.toJson());
  }

  /// Count of signals of [type] for a profile (used by recommendation scoring).
  Future<int> countByType(String profileId, String type,
      {DateTime? since}) async {
    var query = _client
        .from('signals')
        .select('id')
        .eq('profile_id', profileId)
        .eq('signal_type', type);
    if (since != null) query = query.gte('created_at', since.toIso8601String());
    final data = await query;
    return (data as List).length;
  }
}

/// App-facing recorder: dev-mode no-op (dev bypasses Supabase + demo profile
/// ids are not UUIDs) and signal-type validation before persisting.
class SignalRecorder {
  final SignalSink sink;
  final bool enabled;
  final String? Function()? profileIdOf;

  SignalRecorder({
    required this.sink,
    required this.enabled,
    this.profileIdOf,
  });

  Future<void> record(
    String type, {
    String? ideaCardId,
    Map<String, dynamic> payload = const {},
  }) async {
    if (!enabled) return;
    if (!SignalModel.allowedTypes.contains(type)) return;
    final profileId = profileIdOf?.call();
    if (profileId == null) return;
    await sink.record(SignalModel(
      profileId: profileId,
      ideaCardId: ideaCardId,
      signalType: type,
      payload: payload,
    ));
  }
}
