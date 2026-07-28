import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rever/src/data/models/concept_model.dart';
import 'package:rever/src/data/models/learning_object_model.dart';

class ConceptRepository {
  final SupabaseClient _client;
  ConceptRepository(this._client);

  Future<List<ConceptModel>> fetchAll() async {
    final data = await _client
        .from('concepts')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => ConceptModel.fromJson(e)).toList();
  }

  Future<List<ConceptModel>> fetchByTopic(String topicId) async {
    final linkData = await _client
        .from('concept_topics')
        .select('concept_id')
        .eq('topic_id', topicId);
    final conceptIds =
        (linkData as List).map((e) => e['concept_id'] as String).toList();
    if (conceptIds.isEmpty) return [];

    final data = await _client
        .from('concepts')
        .select()
        .inFilter('id', conceptIds)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ConceptModel.fromJson(e)).toList();
  }

  Future<ConceptModel?> fetchBySlug(String slug) async {
    final data = await _client
        .from('concepts')
        .select()
        .eq('slug', slug)
        .maybeSingle();
    if (data == null) return null;
    return ConceptModel.fromJson(data);
  }

  Future<List<LearningObjectModel>> fetchLearningObjects(String conceptId) async {
    final data = await _client
        .from('learning_objects')
        .select()
        .eq('concept_id', conceptId)
        .order('created_at', ascending: true);
    return (data as List).map((e) => LearningObjectModel.fromJson(e)).toList();
  }
}
