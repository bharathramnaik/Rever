import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/topic_model.dart';
import 'package:rever/src/data/repositories/topic_repository.dart';

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return TopicRepository(ref.watch(supabaseProvider));
});

final topicsProvider = FutureProvider<List<TopicModel>>((ref) {
  return ref.watch(topicRepositoryProvider).fetchAll();
});
