/// Duplicate detection for generated ideas (flow.txt §7).
/// Token-set (Jaccard) similarity on normalized text; a card is a duplicate
/// when similarity exceeds the threshold.
class DuplicateDetector {
  final double threshold;
  const DuplicateDetector({this.threshold = 0.85});

  static const _stopwords = {
    'the', 'a', 'an', 'and', 'or', 'of', 'to', 'in', 'on', 'for', 'with',
    'is', 'are', 'that', 'this', 'it', 'you', 'your', 'how', 'what', 'why',
    'can', 'do', 'does', 'not', 'be', 'by', 'as', 'at', 'from', 'we', 'our',
  };

  /// Normalized token set of [text].
  static Set<String> tokensOf(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.isNotEmpty && t.length > 2 && !_stopwords.contains(t))
        .toSet();
  }

  /// Jaccard similarity between two texts, 0..1.
  static double similarity(String a, String b) {
    final ta = tokensOf(a);
    final tb = tokensOf(b);
    if (ta.isEmpty || tb.isEmpty) return 0;
    final union = ta.union(tb).length;
    if (union == 0) return 0;
    return ta.intersection(tb).length / union;
  }

  /// True when [text] is a duplicate of any card in [existing].
  bool isDuplicate(String text, List<String> existingTexts) {
    for (final existing in existingTexts) {
      if (similarity(text, existing) >= threshold) return true;
    }
    return false;
  }
}
