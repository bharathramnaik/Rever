import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/environment.dart';
import '../models/preferences_model.dart';

class PreferenceRepository {
  final SupabaseClient _client;
  final Map<String, PreferencesModel> _memory = {};

  PreferenceRepository(this._client);

  Future<PreferencesModel?> fetch(String profileId) async {
    if (!AppEnvironment.isDev) {
      try {
        final data = await _client
            .from('preferences')
            .select()
            .eq('profile_id', profileId)
            .maybeSingle();
        if (data != null) return PreferencesModel.fromJson(data);
      } catch (_) {}
    }
    return _memory[profileId];
  }

  Future<void> save(PreferencesModel preferences) async {
    if (!AppEnvironment.isDev) {
      try {
        await _client
            .from('preferences')
            .upsert(preferences.toJson());
      } catch (_) {}
    }
    _memory[preferences.profileId] = preferences;
  }
}
