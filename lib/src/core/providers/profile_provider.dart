import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/profile_model.dart';

class ActiveProfileNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final activeProfileIdProvider =
    NotifierProvider<ActiveProfileNotifier, String?>(
  ActiveProfileNotifier.new,
);

final activeProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return null;
  final profile = _demoProfiles.firstWhere(
    (p) => p.id == profileId,
    orElse: () => _demoProfiles.first,
  );
  return profile;
});

final profilesProvider = FutureProvider<List<ProfileModel>>((ref) async {
  // Demo profiles are only valid in dev mode. In production, leaking them
  // (e.g. when the anon key has no rows) sends string ids like
  // `dev-bharath` into UUID-typed `profile_id` columns, which Postgres
  // rejects with `invalid input syntax for type uuid` (HTTP 400).
  if (AppEnvironment.isDev) return _demoProfiles;

  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;
  List<dynamic> data;
  if (user != null) {
    data = await client
        .from('profiles')
        .select()
        .eq('account_id', user.id)
        .order('created_at', ascending: true);
  } else {
    data = await client
        .from('profiles')
        .select()
        .order('created_at', ascending: true);
  }
  if (data.isNotEmpty) {
    return data.map((e) => ProfileModel.fromJson(e)).toList();
  }
  return <ProfileModel>[];
});

final _demoProfiles = [
  ProfileModel(
    id: 'dev-bharath',
    accountId: 'dev-account',
    name: 'Bharath',
    profileType: 'adult',
  ),
  ProfileModel(
    id: 'dev-arjun',
    accountId: 'dev-account',
    name: 'Arjun',
    profileType: 'child',
    ageRange: '8',
  ),
  ProfileModel(
    id: 'dev-nikhil',
    accountId: 'dev-account',
    name: 'Nikhil',
    profileType: 'teen',
    ageRange: '15',
  ),
];
