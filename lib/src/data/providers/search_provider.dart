import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/data/models/concept_model.dart';
import 'package:rever/src/data/models/topic_model.dart';
import 'package:rever/src/data/models/source_model.dart';

/// Notifier for current search query
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Unified search results across concepts, topics, and sources
final searchResultsProvider = FutureProvider<SearchResults>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return SearchResults.empty();

  final client = ref.watch(supabaseProvider);
  final lowerQuery = '%${query.toLowerCase()}%';

  // Search concepts
  final conceptData = await client
      .from('concepts')
      .select()
      .or('title.ilike.$lowerQuery,summary.ilike.$lowerQuery')
      .limit(10);
  final concepts =
      (conceptData as List).map((e) => ConceptModel.fromJson(e)).toList();

  // Search topics
  final topicData = await client
      .from('topics')
      .select()
      .or('name.ilike.$lowerQuery,description.ilike.$lowerQuery')
      .limit(10);
  final topics =
      (topicData as List).map((e) => TopicModel.fromJson(e)).toList();

  // Search sources
  final sourceData = await client
      .from('sources')
      .select()
      .ilike('title', lowerQuery)
      .limit(10);
  final sources =
      (sourceData as List).map((e) => SourceModel.fromJson(e)).toList();

  return SearchResults(
    concepts: concepts,
    topics: topics,
    sources: sources,
  );
});

class SearchResults {
  final List<ConceptModel> concepts;
  final List<TopicModel> topics;
  final List<SourceModel> sources;

  const SearchResults({
    required this.concepts,
    required this.topics,
    required this.sources,
  });

  factory SearchResults.empty() => const SearchResults(
        concepts: [],
        topics: [],
        sources: [],
      );

  bool get isEmpty => concepts.isEmpty && topics.isEmpty && sources.isEmpty;
  int get totalCount => concepts.length + topics.length + sources.length;
}
