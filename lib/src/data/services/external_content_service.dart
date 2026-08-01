import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/data/models/explore_content_model.dart';
import 'package:rever/src/data/models/preferences_model.dart';
import 'package:rever/src/data/models/stash_card_model.dart';
import 'package:rever/src/data/providers/preferences_provider.dart';

class ExternalContentService {
  final Dio _dio;

  ExternalContentService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  Future<List<ExploreContent>> discoverBooks({
    int limit = 10,
    String? topic,
  }) async {
    const fallbackTopics = [
      'philosophy',
      'science',
      'art',
      'history',
      'psychology',
    ];
    final effectiveTopic = topic ??
        fallbackTopics[DateTime.now().millisecondsSinceEpoch ~/ 60000 %
            fallbackTopics.length];
    final response = await _dio.get(
      'https://openlibrary.org/search.json',
      queryParameters: {'q': effectiveTopic, 'limit': limit, 'sort': 'rating'},
    );
    final docs = response.data['docs'] as List? ?? [];
    return docs.map((d) => _bookFromDoc(d, effectiveTopic)).toList();
  }

  Future<List<ExploreContent>> discoverArticles({int limit = 5}) async {
    final results = <ExploreContent>[];
    final seen = <String>{};
    int attempts = 0;
    while (results.length < limit && attempts < limit * 3) {
      attempts++;
      try {
        final response = await _dio.get(
          'https://en.wikipedia.org/api/rest_v1/page/random/summary',
        );
        final data = response.data as Map<String, dynamic>;
        final title = data['title'] as String? ?? '';
        if (title.isEmpty || seen.contains(title)) continue;
        seen.add(title);
        results.add(_articleFromResponse(data));
      } catch (_) {}
    }
    return results;
  }

  Future<List<ExploreContent>> searchBooks(String query) async {
    final response = await _dio.get(
      'https://openlibrary.org/search.json',
      queryParameters: {'q': query, 'limit': 15},
    );
    final docs = response.data['docs'] as List? ?? [];
    return docs.map((d) => _bookFromDoc(d)).toList();
  }

  Future<List<ExploreContent>> trending({List<String> topics = const []}) async {
    final topic = topics.isNotEmpty ? topicSearchQuery(topics.first) : null;
    final books = await discoverBooks(limit: 5, topic: topic);
    final articles = await discoverArticles(limit: 3);
    return [...books, ...articles]..shuffle();
  }

  Future<ExploreContent> fetchDetail(ExploreContent item) async {
    if (item.source == ContentSource.book) {
      return _fetchBookDetail(item);
    }
    return _fetchArticleDetail(item);
  }

  Future<ExploreContent> _fetchBookDetail(ExploreContent item) async {
    final workId = item.id.replaceAll('/works/', '');
    try {
      final response = await _dio.get(
        'https://openlibrary.org/works/$workId.json',
      );
      final data = response.data as Map<String, dynamic>;
      final desc = data['description'];
      final description = desc is Map<String, dynamic>
          ? desc['value'] as String?
          : desc as String?;
      final subjects = (data['subjects'] as List?)
              ?.map((s) => s.toString())
              .toList() ??
          [];
      final excerpts = data['excerpts'] as List?;
      final keyPoints = excerpts
              ?.take(5)
              .map((e) =>
                  (e as Map<String, dynamic>)['excerpt'] as String? ?? '')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [];

      return ExploreContent(
        id: item.id,
        title: item.title,
        description: description ?? item.description,
        fullContent: description,
        thumbnailUrl: item.thumbnailUrl,
        source: item.source,
        author: item.author,
        url: item.url,
        category: item.category,
        subjects: subjects,
        keyPoints: keyPoints,
      );
    } catch (_) {
      return item;
    }
  }

  Future<ExploreContent> _fetchArticleDetail(ExploreContent item) async {
    try {
      final title = item.title;
      final response = await _dio.get(
        'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(title)}',
      );
      final data = response.data as Map<String, dynamic>;
      return _articleFromResponse(data);
    } catch (_) {
      return item;
    }
  }

  ExploreContent _bookFromDoc(Map<String, dynamic> d, [String? topic]) {
    final coverId = d['cover_i'];
    final authorKey = (d['author_key'] as List?)?.firstOrNull as String?;
    return ExploreContent(
      id: d['key'] as String? ?? '',
      title: d['title'] as String? ?? 'Untitled',
      description: d['first_sentence'] as String?,
      thumbnailUrl: coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
          : null,
      source: ContentSource.book,
      author: (d['author_name'] as List?)?.firstOrNull as String?,
      url: authorKey != null
          ? 'https://openlibrary.org/authors/$authorKey'
          : null,
      category: topic,
      subjects: (d['subject'] as List?)
              ?.take(10)
              .map((s) => s.toString())
              .toList() ??
          [],
      keyPoints: const [],
    );
  }

  ExploreContent _articleFromResponse(Map<String, dynamic> data) {
    final extract = data['extract'] as String?;
    final thumbnail = data['thumbnail'] as Map<String, dynamic>?;
    final contentUrls = data['content_urls'] as Map<String, dynamic>?;
    final desktop = contentUrls?['desktop'] as Map<String, dynamic>?;
    return ExploreContent(
      id: data['pageid']?.toString() ?? '',
      title: data['title'] as String? ?? '',
      description:
          extract != null && extract.length > 200 ? extract : extract,
      fullContent: extract,
      thumbnailUrl: thumbnail?['source'] as String?,
      source: ContentSource.article,
      url: desktop?['page'] as String? ??
          'https://en.wikipedia.org/wiki/${Uri.encodeComponent(data['title'] as String? ?? '')}',
      subjects: (data['categories'] as List?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      keyPoints: _extractKeyPoints(extract),
    );
  }

  List<String> _extractKeyPoints(String? extract) {
    if (extract == null) return [];
    final sentences = extract.split(RegExp(r'(?<=[.!?])\s+'));
    return sentences.take(5).toList();
  }

  List<StashCard> generateStashes(ExploreContent item) {
    final stashes = <StashCard>[];

    if (item.source == ContentSource.book) {
      stashes.addAll(_bookStashes(item));
    } else {
      stashes.addAll(_articleStashes(item));
    }

    return stashes;
  }

  List<StashCard> _bookStashes(ExploreContent item) {
    final cards = <StashCard>[];

    final cleanDesc = _cleanText(item.description ?? '');
    if (cleanDesc.isNotEmpty) {
      cards.add(StashCard(
        title: 'About this book',
        content: cleanDesc,
        type: StashType.overview,
      ));
    }

    if (item.keyPoints.isNotEmpty) {
      for (var i = 0; i < item.keyPoints.length; i++) {
        final clean = _cleanText(item.keyPoints[i]);
        if (clean.isNotEmpty) {
          cards.add(StashCard(
            title: 'Idea ${i + 1}',
            content: clean,
          ));
        }
      }
    }

    if (cleanDesc.isNotEmpty && item.keyPoints.isEmpty) {
      final chunks = _chunkText(cleanDesc, 150);
      for (var i = 0; i < chunks.length; i++) {
        cards.add(StashCard(
          title: i == 0 ? 'Overview' : 'Takeaway ${i}',
          content: chunks[i],
        ));
      }
    }

    return cards;
  }

  List<StashCard> _articleStashes(ExploreContent item) {
    final cards = <StashCard>[];

    final clean = _cleanText(item.description ?? item.fullContent ?? '');
    if (clean.isEmpty) return cards;

    if (clean.length < 200) {
      cards.add(StashCard(
        title: 'Summary',
        content: clean,
        type: StashType.overview,
      ));
      return cards;
    }

    final sentences = _splitSentences(clean);
    final mid = sentences.length ~/ 2;

    final firstHalf = sentences.take(mid).join(' ');
    if (firstHalf.length > 60) {
      cards.add(StashCard(
        title: 'Summary',
        content: firstHalf,
        type: StashType.overview,
      ));
    }

    final secondHalf = sentences.skip(mid).join(' ');
    if (secondHalf.length > 60) {
      cards.add(StashCard(
        title: 'Key details',
        content: secondHalf,
      ));
    }

    return cards;
  }

  String _cleanText(String text) {
    String result = text;
    result = result.replaceAll(RegExp(r'[*_~`#]'), '');
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();
    return result;
  }

  List<String> _chunkText(String text, int maxLen) {
    final sentences = _splitSentences(text);
    final chunks = <String>[];
    var current = '';
    for (final s in sentences) {
      if ((current + ' ' + s).length > maxLen && current.isNotEmpty) {
        chunks.add(current.trim());
        current = s;
      } else {
        current = current.isEmpty ? s : '$current $s';
      }
    }
    if (current.trim().isNotEmpty) chunks.add(current.trim());
    return chunks;
  }

  List<String> _splitSentences(String text) {
    return text
        .split(RegExp(r'(?<=[.!?])\s+(?=[A-Z])'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

final externalContentServiceProvider = Provider<ExternalContentService>((ref) {
  return ExternalContentService();
});

final trendingContentProvider = FutureProvider<List<ExploreContent>>((ref) async {
  final prefs = await ref.watch(activePreferencesProvider.future);
  return ref
      .watch(externalContentServiceProvider)
      .trending(topics: prefs?.topics ?? const []);
});

final searchBooksProvider =
    FutureProvider.family<List<ExploreContent>, String>((ref, query) {
  if (query.trim().isEmpty) return Future.value([]);
  return ref.watch(externalContentServiceProvider).searchBooks(query);
});

final contentDetailProvider =
    FutureProvider.family<ExploreContent, ExploreContent>((ref, item) {
  return ref.watch(externalContentServiceProvider).fetchDetail(item);
});

final contentStashesProvider =
    FutureProvider.family<List<StashCard>, ExploreContent>((ref, item) async {
  final detailed =
      await ref.watch(externalContentServiceProvider).fetchDetail(item);
  return ref.watch(externalContentServiceProvider).generateStashes(detailed);
});
