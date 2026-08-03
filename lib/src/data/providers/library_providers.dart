import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/learning_object_model.dart';
import 'package:rever/src/data/repositories/idea_card_repository.dart';
import 'package:rever/src/data/repositories/learning_repository.dart';

final libraryRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepository(ref.watch(supabaseProvider));
});

final ideaCardRepositoryProvider = Provider<IdeaCardRepository>((ref) {
  return IdeaCardRepository(ref.watch(supabaseProvider));
});

final savedObjectsProvider =
    FutureProvider.family<List<LearningObjectModel>, String>(
        (ref, profileId) {
  return ref.watch(libraryRepositoryProvider).fetchSaved(profileId);
});
