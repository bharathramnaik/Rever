import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rever/src/data/models/idea_card_model.dart';

class IdeaCardRepository {
  final SupabaseClient _client;
  IdeaCardRepository(this._client);

  Future<List<IdeaCard>> fetchFeed({int limit = 20}) async {
    final data = await _client
        .from('idea_cards')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => IdeaCard.fromJson(e)).toList();
  }

  Future<void> reactToCard(String cardId, String reaction) async {
    final column = switch (reaction) {
      'like' => 'like_count',
      'mind_blown' => 'mind_blown_count',
      'actionable' => 'actionable_count',
      _ => 'like_count',
    };
    await _client.rpc('increment_card_reaction', params: {
      'card_id': cardId,
      'column_name': column,
    });
  }

  Future<void> addToStash(String stashId, String cardId) async {
    await _client.from('stash_items').insert({
      'stash_id': stashId,
      'idea_card_id': cardId,
    });
  }

  /// Persist generated idea cards (from the Create flow) to Supabase.
  /// Returns the inserted cards with their generated IDs.
  Future<List<IdeaCard>> saveCards(List<IdeaCard> cards) async {
    if (cards.isEmpty) return [];
    final rows = cards
        .map((c) => {
              'takeaway': c.takeaway,
              'body': c.body,
              if (c.sourceId != null) 'source_id': c.sourceId,
              if (c.conceptId != null) 'concept_id': c.conceptId,
              if (c.quote != null) 'quote': c.quote,
            })
        .toList();
    final data = await _client.from('idea_cards').insert(rows).select();
    return (data as List).map((e) => IdeaCard.fromJson(e)).toList();
  }

  Future<List<IdeaCard>> fetchByStash(String stashId) async {
    final data = await _client
        .from('stash_items')
        .select('idea_cards(*)')
        .eq('stash_id', stashId);
    return (data as List)
        .map((e) => IdeaCard.fromJson(e['idea_cards'] as Map<String, dynamic>))
        .toList();
  }
}
