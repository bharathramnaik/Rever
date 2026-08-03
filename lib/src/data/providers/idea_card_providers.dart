import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/config/environment.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/core/services/content_generator.dart';
import 'package:rever/src/core/services/llm_service.dart';
import 'package:rever/src/core/services/local_idea_store.dart';
import 'package:rever/src/data/models/idea_card_model.dart';
import 'package:rever/src/data/models/stash_model.dart';
import 'package:rever/src/data/repositories/idea_card_repository.dart';

final ideaCardRepositoryProvider = Provider<IdeaCardRepository>((ref) {
  return IdeaCardRepository(ref.watch(supabaseProvider));
});

final contentGeneratorProvider = Provider<ContentGenerator>((ref) {
  final llm = ref.watch(llmServiceProvider);
  return ContentGenerator(llm.complete);
});

final localIdeaStoreProvider =
    FutureProvider<LocalIdeaStore>((ref) => LocalIdeaStore.create());

/// In dev mode the demo profile ids (e.g. `dev-bharath`) are not real UUIDs,
/// so profile-scoped Supabase queries throw `invalid input syntax for type
/// uuid` (22P02). Per the architecture ("dev bypasses Supabase entirely"),
/// dev reads come from the local store; production reads come from Supabase.
final userStashProvider =
    FutureProvider.family<Stash?, String>((ref, profileId) {
  if (AppEnvironment.isDev) return null;
  return ref.watch(ideaCardRepositoryProvider).getPersonalStash(profileId);
});

final userStashedCardsProvider =
    FutureProvider.family<List<IdeaCard>, String>((ref, profileId) {
  if (AppEnvironment.isDev) {
    return ref.watch(localIdeaStoreProvider.future).then((s) => s.loadAll());
  }
  return ref.watch(ideaCardRepositoryProvider).fetchStashed(profileId);
});

final localIdeaCardsProvider = FutureProvider<List<IdeaCard>>((ref) {
  return ref.watch(localIdeaStoreProvider.future).then((s) => s.loadAll());
});
