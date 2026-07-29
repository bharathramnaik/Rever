/// SM-2 Spaced Repetition Algorithm
///
/// Implements the SuperMemo SM-2 algorithm for scheduling review intervals.
/// See: https://www.supermemo.com/en/blog/application-of-a-computer-to-improve-the-results-of-student-self-assessment

class SpacedRepetitionResult {
  final double easeFactor;
  final int repetitionCount;
  final int intervalDays;
  final DateTime nextReviewAt;

  const SpacedRepetitionResult({
    required this.easeFactor,
    required this.repetitionCount,
    required this.intervalDays,
    required this.nextReviewAt,
  });
}

class SpacedRepetitionEngine {
  static const double minEaseFactor = 1.3;
  static const double defaultEaseFactor = 2.5;

  /// Calculate the next review based on SM-2 algorithm
  ///
  /// [quality] — response quality (0-5):
  ///   0: Complete blackout
  ///   1: Incorrect; correct answer remembered upon seeing it
  ///   2: Incorrect; correct answer seemed easy to recall
  ///   3: Correct; recalled with serious difficulty
  ///   4: Correct; recalled after hesitation
  ///   5: Correct; perfect recall
  ///
  /// [currentEaseFactor] — current ease factor (default 2.5)
  /// [currentRepetition] — current repetition count
  static SpacedRepetitionResult calculate({
    required int quality,
    double currentEaseFactor = defaultEaseFactor,
    int currentRepetition = 0,
  }) {
    assert(quality >= 0 && quality <= 5);

    double ef = currentEaseFactor;
    int rep = currentRepetition;
    int interval;

    if (quality < 3) {
      // Failed recall — reset repetitions
      rep = 0;
      interval = 1;
    } else {
      // Successful recall
      rep += 1;
      switch (rep) {
        case 1:
          interval = 1;
        case 2:
          interval = 6;
        default:
          // For n > 2: I(n) = I(n-1) * EF
          interval = _previousInterval(rep - 1, currentEaseFactor);
          interval = (interval * ef).round();
      }
    }

    // Update ease factor
    ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (ef < minEaseFactor) ef = minEaseFactor;

    final now = DateTime.now();
    final nextReview = DateTime(now.year, now.month, now.day + interval);

    return SpacedRepetitionResult(
      easeFactor: ef,
      repetitionCount: rep,
      intervalDays: interval,
      nextReviewAt: nextReview,
    );
  }

  /// Calculate interval for a given repetition count (recursive definition)
  static int _previousInterval(int rep, double ef) {
    if (rep <= 0) return 0;
    if (rep == 1) return 1;
    if (rep == 2) return 6;
    return (_previousInterval(rep - 1, ef) * ef).round();
  }

  /// Convert a mastery level (0.0 - 1.0) to an SM-2 quality score (0-5)
  static int masteryToQuality(double mastery) {
    if (mastery >= 0.95) return 5;
    if (mastery >= 0.80) return 4;
    if (mastery >= 0.60) return 3;
    if (mastery >= 0.40) return 2;
    if (mastery >= 0.20) return 1;
    return 0;
  }

  /// Convert quiz percentage (0-100) to SM-2 quality score
  static int quizScoreToQuality(double scorePercent) {
    if (scorePercent >= 95) return 5;
    if (scorePercent >= 80) return 4;
    if (scorePercent >= 60) return 3;
    if (scorePercent >= 40) return 2;
    if (scorePercent >= 20) return 1;
    return 0;
  }
}
