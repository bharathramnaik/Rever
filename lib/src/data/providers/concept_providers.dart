import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/concept_model.dart';
import 'package:rever/src/data/models/learning_object_model.dart';
import 'package:rever/src/data/repositories/concept_repository.dart';

final conceptRepositoryProvider = Provider<ConceptRepository>((ref) {
  return ConceptRepository(ref.watch(supabaseProvider));
});

final allConceptsProvider = FutureProvider<List<ConceptModel>>((ref) {
  return ref.watch(conceptRepositoryProvider).fetchAll();
});

final conceptsByTopicProvider =
    FutureProvider.family<List<ConceptModel>, String>((ref, topicId) {
  return ref.watch(conceptRepositoryProvider).fetchByTopic(topicId);
});

final conceptBySlugProvider =
    FutureProvider.family<ConceptModel?, String>((ref, slug) {
  return ref.watch(conceptRepositoryProvider).fetchBySlug(slug);
});

final learningObjectsProvider =
    FutureProvider.family<List<LearningObjectModel>, String>((ref, conceptId) {
  return ref.watch(conceptRepositoryProvider).fetchLearningObjects(conceptId);
});
