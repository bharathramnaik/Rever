import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rever/src/data/models/source_model.dart';

class SourceRepository {
  final SupabaseClient _client;
  SourceRepository(this._client);

  Future<List<SourceModel>> fetchAll() async {
    final data = await _client.from('sources').select().order('title');
    return (data as List).map((e) => SourceModel.fromJson(e)).toList();
  }
}
