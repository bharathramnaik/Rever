import 'dart:async';
import 'dart:convert';

import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

/// Result of fetching + extracting text from a web URL.
class UrlFetchResult {
  final String title;
  final String text;
  const UrlFetchResult({required this.title, required this.text});
}

/// Fetches a URL and strips it down to readable text for LLM distillation.
///
/// No key is needed; pure client-side fetch with a browser-like user agent so
/// most public pages serve their HTML. Non-HTML (PDF etc.) or unreachable
/// pages return null and callers fall back to sending the raw URL.
class UrlTextFetcher {
  final http.Client _client;

  UrlTextFetcher({http.Client? client}) : _client = client ?? http.Client();

  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/120.0 Mobile Safari/537.36 Rever/1.0';

  static const _maxChars = 100000;

  Future<UrlFetchResult?> fetch(String url) async {
    try {
      final resp = await _client
          .get(
            Uri.parse(url),
            headers: {'User-Agent': _userAgent, 'Accept': 'text/html'},
          )
          .timeout(const Duration(seconds: 20));
      if (resp.statusCode != 200) return null;

      final contentType = resp.headers['content-type'] ?? '';
      if (contentType.contains('application/pdf') ||
          contentType.contains('application/octet-stream')) {
        return null;
      }

      // Try to decode as UTF-8 (common case); fall back to latin-1.
      String body;
      try {
        body = utf8.decode(resp.bodyBytes);
      } catch (_) {
        body = latin1.decode(resp.bodyBytes);
      }

      final doc = html.parse(body);
      for (final tag in doc.querySelectorAll(
        'script, style, noscript, iframe, nav, footer, header, form',
      )) {
        tag.remove();
      }
      final title = doc.querySelector('title')?.text.trim() ?? '';
      final text = (doc.body?.text ?? '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (text.isEmpty) return null;
      return UrlFetchResult(
        title: title,
        text: text.length > _maxChars ? text.substring(0, _maxChars) : text,
      );
    } catch (e) {
      return null;
    }
  }
}
