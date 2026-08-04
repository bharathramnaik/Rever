import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/data/models/book_access_model.dart';

/// Per-profile book (source) access, capped at 3 per profile.
///
/// Production: `book_access` table in Supabase; the owner grants via
/// dashboard (service role).
/// Dev mode: device cache; requests auto-grant so the owner can test the
/// micro-learning flow end-to-end without dashboard access.
class BookAccessRepository {
  static const _localKey = 'local_book_access';
  static const _accessCap = 3;

  final SupabaseClient? _client;
  final SharedPreferences? _prefs;

  BookAccessRepository(this._client, this._prefs);

  Future<List<BookAccessModel>> fetchForProfile(String profileId) async {
    if (AppEnvironment.isDev || _client == null || _prefs == null) {
      return (await _localList()).where((a) => a.profileId == profileId).toList();
    }
    final data = await _client
        .from('book_access')
        .select()
        .eq('profile_id', profileId);
    return (data as List)
        .map((e) => BookAccessModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> request(String profileId, String sourceId) async {
    if (AppEnvironment.isDev || _client == null || _prefs == null) {
      final all = await _localList();
      all.removeWhere(
        (a) => a.profileId == profileId && a.sourceId == sourceId,
      );
      // Auto-grant in dev so the flow is testable without the dashboard.
      all.add(
        BookAccessModel(
          profileId: profileId,
          sourceId: sourceId,
          status: AppEnvironment.isDev ? 'granted' : 'requested',
          createdAt: DateTime.now(),
        ),
      );
      await _saveLocal(all);
      return;
    }
    await _client.from('book_access').insert({
      'profile_id': profileId,
      'source_id': sourceId,
    });
  }

  Future<List<BookAccessModel>> _localList() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => BookAccessModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveLocal(List<BookAccessModel> all) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _localKey,
      jsonEncode([
        for (final a in all)
          {
            'profile_id': a.profileId,
            'source_id': a.sourceId,
            'status': a.status,
            'created_at': a.createdAt.toIso8601String(),
          }
      ]),
    );
  }
}

/// Access gate used by the UI:
/// - [statusFor] returns the access row for one profile+source (or null).
/// - [activeCount] counts requested|granted rows against the 3-book cap.
/// - [canRequestMore] is false once the cap is reached.
class BookAccessGate {
  final List<BookAccessModel> access;

  const BookAccessGate(this.access);

  BookAccessModel? statusFor(String sourceId) {
    for (final a in access) {
      if (a.sourceId == sourceId) return a;
    }
    return null;
  }

  int get activeCount =>
      access.where((a) => a.countsTowardCap).length;

  bool get canRequestMore => activeCount < BookAccessRepository._accessCap;

  int get remainingSlots =>
      (BookAccessRepository._accessCap - activeCount).clamp(0, 100);
}
