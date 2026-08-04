import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/data/models/submission_model.dart';

/// Persists user-published articles.
///
/// Production: `submissions` table in Supabase (profile-scoped insert, RLS
/// lets every profile read approved rows).
/// Dev mode: demo profile ids are not real UUIDs, so submissions go to the
/// device cache only (same pattern as idea cards).
class SubmissionRepository {
  static const _localKey = 'local_submissions';

  final SupabaseClient? _client;
  final SharedPreferences? _prefs;

  SubmissionRepository(this._client, this._prefs);

  Future<List<SubmissionModel>> fetchMine(String profileId) async {
    if (AppEnvironment.isDev || _client == null || _prefs == null) {
      return (await _localList()).where((s) => s.profileId == profileId).toList();
    }
    final data = await _client
        .from('submissions')
        .select()
        .eq('profile_id', profileId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => SubmissionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> submit(String profileId, String title, String body) async {
    if (AppEnvironment.isDev || _client == null || _prefs == null) {
      final all = await _localList();
      all.insert(
        0,
        SubmissionModel(
          id: 'local-${DateTime.now().microsecondsSinceEpoch}',
          profileId: profileId,
          title: title,
          body: body,
          status: 'pending',
          createdAt: DateTime.now(),
        ),
      );
      await _saveLocal(all);
      return;
    }
    await _client.from('submissions').insert({
      'profile_id': profileId,
      'title': title,
      'body': body,
    });
  }

  Future<void> withdraw(String id) async {
    if (AppEnvironment.isDev || _client == null || _prefs == null) {
      final all = await _localList();
      all.removeWhere((s) => s.id == id);
      await _saveLocal(all);
      return;
    }
    await _client.from('submissions').delete().eq('id', id);
  }

  Future<List<SubmissionModel>> _localList() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => SubmissionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveLocal(List<SubmissionModel> all) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _localKey,
      jsonEncode(
        [for (final s in all) {
            'id': s.id,
            'profile_id': s.profileId,
            'title': s.title,
            'body': s.body,
            'status': s.status,
            'created_at': s.createdAt.toIso8601String(),
            if (s.approvedAt != null) 'approved_at': s.approvedAt!.toIso8601String(),
          }],
      ),
    );
  }
}
