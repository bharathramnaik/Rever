import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:rever/src/data/models/stash_model.dart';

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

  Future<List<IdeaCard>> fetchByStash(String stashId) async {
    final data = await _client
        .from('stash_items')
        .select('idea_cards(*)')
        .eq('stash_id', stashId);
    return (data as List)
        .map((e) => IdeaCard.fromJson(e['idea_cards'] as Map<String, dynamic>))
        .toList();
  }

  /// Gets or creates the user's default "Saved" collection.
  Future<Stash?> getPersonalStash(String profileId) async {
    final existing = await _client
        .from('stashes')
        .select()
        .eq('profile_id', profileId)
        .eq('title', 'Saved')
        .maybeSingle();
    if (existing != null) return Stash.fromJson(existing);
    final data = await _client.from('stashes').insert({
      'profile_id': profileId,
      'title': 'Saved',
      'description': 'Ideas you saved from your library',
      'is_private': true,
      'color_hex': '#6C63FF',
    }).select().maybeSingle();
    return data == null ? null : Stash.fromJson(data);
  }

  /// All idea cards saved into the user's collections.
  Future<List<IdeaCard>> fetchStashed(String profileId) async {
    final data = await _client
        .from('stash_items')
        .select('idea_cards!inner(*), stashes!inner!inner(profile_id)')
        .eq('stashes.profile_id', profileId)
        .order('added_at', ascending: false);
    return (data as List)
        .map((e) => IdeaCard.fromJson(e['idea_cards'] as Map<String, dynamic>))
        .toList();
  }

  /// Persist user-generated idea cards (from the Create flow) under a source
  /// and a default "Created" stash. Returns the inserted cards with their
  /// real IDs (used to wire knowledge-graph edges).
  Future<List<IdeaCard>> saveGenerated(
    String profileId,
    List<IdeaCard> cards, {
    String? sourceId,
  }) async {
    final stash = await getPersonalStash(profileId);
    final stashId = stash?.id;
    final insertedCards = <IdeaCard>[];

    for (final card in cards) {
      final inserted = await _client
          .from('idea_cards')
          .insert({
            'source_id': sourceId,
            'takeaway': card.takeaway,
            'body': card.body,
            'quote': card.quote,
            'audio_url': card.audioUrl,
            'difficulty': card.difficulty,
            'quality_score': card.qualityScore,
            'language': card.language,
            'status': card.status,
            'takeaways': card.takeaways,
            'examples': card.examples,
            'questions': card.questions,
            'flashcards': [for (final f in card.flashcards) f.toJson()],
          })
          .select()
          .maybeSingle();
      if (inserted == null) continue;
      final cardId = inserted['id'] as String;
      if (stashId != null) {
        await addToStash(stashId, cardId);
      }
      insertedCards.add(IdeaCard.fromJson(inserted));
    }
    return insertedCards;
  }
}

