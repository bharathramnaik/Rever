import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rever/src/data/models/idea_card_model.dart';

/// Local fallback store for idea cards on the current device.
///
/// Used when the Supabase write path is unavailable (e.g. dev mode where
/// `dev-*` profile ids are not real rows in the `profiles` table, so the RLS
/// policy on `stashes`/`stash_items` would reject the insert). Keeps user
/// actions durable so "Save" never silently does nothing.
class LocalIdeaStore {
  static const _kKey = 'rever_local_idea_cards';

  final SharedPreferences _prefs;

  LocalIdeaStore(this._prefs);

  static Future<LocalIdeaStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalIdeaStore(prefs);
  }

  List<IdeaCard> loadAll() {
    final raw = _prefs.getStringList(_kKey);
    if (raw == null || raw.isEmpty) return [];
    return raw
        .map((s) {
          try {
            return IdeaCard.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<IdeaCard>()
        .toList();
  }

  Future<void> save(IdeaCard card) async {
    final all = loadAll();
    all.removeWhere((c) => c.id == card.id);
    all.insert(0, card);
    await _write(all);
  }

  Future<void> _write(List<IdeaCard> cards) async {
    final encoded =
        cards.map((c) => jsonEncode(c.toJson())).toList(growable: false);
    await _prefs.setStringList(_kKey, encoded);
  }

  Future<void> remove(String cardId) async {
    final all = loadAll();
    all.removeWhere((c) => c.id == cardId);
    await _write(all);
  }

  @visibleForTesting
  static const String testKey = _kKey;
}
