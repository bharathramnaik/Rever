import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rever/src/core/providers/auth_provider.dart';
import 'package:rever/src/core/utils/app_logger.dart';
import 'package:rever/src/data/models/quote_model.dart';

final _dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 8),
  receiveTimeout: const Duration(seconds: 12),
));

final randomQuoteProvider = FutureProvider<Quote?>((ref) async {
  final client = ref.watch(supabaseProvider);
  try {
    final data = await client
        .from('quotes')
        .select()
        .order('random', ascending: true)
        .limit(1)
        .maybeSingle();
    if (data != null) return Quote.fromJson(data);
  } catch (e) {
    appLogger.w('Supabase quote fetch failed, trying Quotable', error: e);
  }
  try {
    final response = await _dio.get(
      'https://api.quotable.io/quotes/random?maxLength=200',
    );
    final list = response.data as List;
    if (list.isNotEmpty) {
      final q = list[0] as Map<String, dynamic>;
      return Quote(
        id: q['_id'] as String? ?? '',
        text: q['content'] as String? ?? '',
        author: q['author'] as String? ?? 'Unknown',
        category: (q['tags'] as List?)?.firstOrNull as String?,
      );
    }
  } catch (e) {
    appLogger.w('Quotable fetch failed, trying ZenQuotes', error: e);
  }
  try {
    final response = await _dio.get(
      'https://zenquotes.io/api/random',
    );
    final list = response.data as List;
    if (list.isNotEmpty) {
      final q = list[0] as Map<String, dynamic>;
      return Quote(
        id: q['q'] as String? ?? '',
        text: q['q'] as String? ?? '',
        author: q['a'] as String? ?? 'Unknown',
      );
    }
  } catch (e) {
    appLogger.e('All quote sources failed', error: e);
  }
  return null;
});
