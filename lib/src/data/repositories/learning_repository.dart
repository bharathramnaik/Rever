import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/data/models/learning_object_model.dart';

class LearningRepository {
  final SupabaseClient _client;
  LearningRepository(this._client);

  Future<List<LearningObjectModel>> fetchSaved(String profileId) async {
    if (AppEnvironment.isDev) return <LearningObjectModel>[];
    try {
      final data = await _client
          .from('saved_objects')
          .select('learning_objects(*)')
          .eq('profile_id', profileId)
          .order('saved_at', ascending: false);
      return (data as List)
          .map((e) => LearningObjectModel.fromJson(e['learning_objects']))
          .toList();
    } catch (e, st) {
      debugPrint('[learning] fetchSaved failed: $e\n$st');
      return <LearningObjectModel>[];
    }
  }

  Future<void> saveObject(String profileId, String objectId,
      {String? notes}) async {
    if (AppEnvironment.isDev) return;
    try {
      await _client.from('saved_objects').upsert({
        'profile_id': profileId,
        'learning_object_id': objectId,
        'notes': notes,
      });
    } catch (e, st) {
      debugPrint('[learning] saveObject failed: $e\n$st');
    }
  }

  Future<void> unsaveObject(String profileId, String objectId) async {
    if (AppEnvironment.isDev) return;
    try {
      await _client
          .from('saved_objects')
          .delete()
          .eq('profile_id', profileId)
          .eq('learning_object_id', objectId);
    } catch (e, st) {
      debugPrint('[learning] unsaveObject failed: $e\n$st');
    }
  }
}
