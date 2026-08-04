import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/repositories/book_access_repository.dart';

final bookAccessRepositoryProvider = Provider<BookAccessRepository>(
  (ref) => BookAccessRepository(ref.watch(supabaseProvider), null),
);

/// Access rows for one profile, exposed as a gate for cap checks.
final bookAccessGateProvider =
    FutureProvider.family<BookAccessGate, String>((ref, profileId) async {
  final access = await ref
      .watch(bookAccessRepositoryProvider)
      .fetchForProfile(profileId);
  return BookAccessGate(access);
});

/// Convenience: active (requested|granted) access count for a profile.
final bookAccessCountProvider = FutureProvider.family<int, String>(
  (ref, profileId) async {
    final gate = await ref.watch(bookAccessGateProvider(profileId).future);
    return gate.activeCount;
  },
);
