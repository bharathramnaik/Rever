import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/source_model.dart';
import 'package:rever/src/data/repositories/source_repository.dart';

final sourceRepositoryProvider = Provider<SourceRepository>((ref) {
  return SourceRepository(ref.watch(supabaseProvider));
});

final sourcesProvider = FutureProvider<List<SourceModel>>((ref) {
  return ref.watch(sourceRepositoryProvider).fetchAll();
});
