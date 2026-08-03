import 'package:flutter/foundation.dart';
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
      } catch (e, st) {
        debugPrint('[preference] fetch failed: $e\n$st');
      }
    }
    return _memory[profileId];
  }

  Future<void> save(PreferencesModel preferences) async {
    if (!AppEnvironment.isDev) {
      try {
        await _client
            .from('preferences')
            .upsert(preferences.toJson());
      } catch (e, st) {
        debugPrint('[preference] save failed: $e\n$st');
      }
    }
    _memory[preferences.profileId] = preferences;
  }
}
