import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Fetches the full ProfileModel for the active profile
final activeProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId == null) return null;
  final client = ref.watch(supabaseProvider);
  final data = await client
      .from('profiles')
      .select()
      .eq('id', profileId)
      .maybeSingle();
  if (data == null) return null;
  return ProfileModel.fromJson(data);
});

/// Fetches all profiles for the current account (or all profiles if unauthenticated)
final profilesProvider = FutureProvider<List<ProfileModel>>((ref) async {
  final client = ref.watch(supabaseProvider);
  final user = client.auth.currentUser;

  List<dynamic> data;
  if (user != null) {
    // Fetch profiles for this account
    data = await client
        .from('profiles')
        .select()
        .eq('account_id', user.id)
        .order('created_at', ascending: true);
  } else {
    // For demo/unauthenticated mode, fetch all profiles
    data = await client
        .from('profiles')
        .select()
        .order('created_at', ascending: true);
  }
  return data.map((e) => ProfileModel.fromJson(e)).toList();
});
