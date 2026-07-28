import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rever/src/data/models/learning_object_model.dart';

class LearningRepository {
  final SupabaseClient _client;
  LearningRepository(this._client);

  Future<List<LearningObjectModel>> fetchSaved(String profileId) async {
    final data = await _client
        .from('saved_objects')
        .select('learning_objects(*)')
        .eq('profile_id', profileId)
        .order('saved_at', ascending: false);
    return (data as List)
        .map((e) => LearningObjectModel.fromJson(e['learning_objects']))
        .toList();
  }

  Future<void> saveObject(String profileId, String objectId,
      {String? notes}) async {
    await _client.from('saved_objects').upsert({
      'profile_id': profileId,
      'learning_object_id': objectId,
      'notes': ?notes,
    });
  }

  Future<void> unsaveObject(String profileId, String objectId) async {
    await _client
        .from('saved_objects')
        .delete()
        .eq('profile_id', profileId)
        .eq('learning_object_id', objectId);
  }
}
