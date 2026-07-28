import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rever/src/data/models/topic_model.dart';

class TopicRepository {
  final SupabaseClient _client;
  TopicRepository(this._client);

  Future<List<TopicModel>> fetchAll() async {
    final data = await _client
        .from('topics')
        .select()
        .order('sort_order', ascending: true);
    return (data as List).map((e) => TopicModel.fromJson(e)).toList();
  }

  Future<TopicModel?> fetchBySlug(String slug) async {
    final data = await _client
        .from('topics')
        .select()
        .eq('slug', slug)
        .maybeSingle();
    if (data == null) return null;
    return TopicModel.fromJson(data);
  }
}
