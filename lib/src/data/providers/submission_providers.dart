import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/submission_model.dart';
import 'package:rever/src/data/repositories/submission_repository.dart';

final submissionRepositoryProvider = Provider<SubmissionRepository>(
  (ref) => SubmissionRepository(ref.watch(supabaseProvider), null),
);

/// Submissions created by one profile (newest first).
final mySubmissionsProvider =
    FutureProvider.family<List<SubmissionModel>, String>(
  (ref, profileId) async {
    return ref.watch(submissionRepositoryProvider).fetchMine(profileId);
  },
);
