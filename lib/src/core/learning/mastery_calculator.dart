/// Mastery Model — calculates overall mastery from multiple signals
///
/// Combines quiz scores, interaction count, time spent, and repetition history
/// into a single mastery percentage (0.0 – 1.0).

class MasteryCalculator {
  /// Weights for each mastery component
  static const double quizWeight = 0.4;
  static const double interactionWeight = 0.2;
  static const double timeWeight = 0.15;
  static const double repetitionWeight = 0.25;

  /// Calculate mastery level from multiple signals
  ///
  /// Returns a value between 0.0 (no mastery) and 1.0 (full mastery)
  static double calculate({
    double? quizAccuracy, // 0.0 - 1.0 (percentage)
    int interactionCount = 0, // number of learning object interactions
    int totalMinutes = 0, // time spent on this concept
    int repetitionCount = 0, // SM-2 repetition count
    int totalLearningObjects = 1, // total LOs for the concept
  }) {
    // Quiz component (0-1)
    final quizScore = quizAccuracy ?? 0.0;

    // Interaction component — ratio of objects interacted with
    final interactionScore =
        (interactionCount / totalLearningObjects).clamp(0.0, 1.0);

    // Time component — diminishing returns after 30 min
    final timeScore = _timeDecay(totalMinutes, 30);

    // Repetition component — max out at 5 reps
    final repScore = (repetitionCount / 5).clamp(0.0, 1.0);

    final mastery = (quizScore * quizWeight) +
        (interactionScore * interactionWeight) +
        (timeScore * timeWeight) +
        (repScore * repetitionWeight);

    return mastery.clamp(0.0, 1.0);
  }

  /// Diminishing returns function for time spent
  /// Reaches ~63% at targetMinutes, ~86% at 2x, ~95% at 3x
  static double _timeDecay(int actualMinutes, int targetMinutes) {
    if (actualMinutes <= 0) return 0.0;
    return 1.0 - _exp(-actualMinutes / targetMinutes);
  }

  static double _exp(double x) {
    // Approximate e^x using Taylor series (avoid dart:math import)
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 20; i++) {
      term *= x / i;
      result += term;
    }
    return result;
  }

  /// Determine mastery tier label
  static String masteryTier(double mastery) {
    if (mastery >= 0.90) return 'Mastered';
    if (mastery >= 0.70) return 'Proficient';
    if (mastery >= 0.50) return 'Developing';
    if (mastery >= 0.25) return 'Familiar';
    return 'Novice';
  }

  /// Get the color index (0-4) for a mastery level
  static int masteryColorIndex(double mastery) {
    if (mastery >= 0.90) return 4; // Green
    if (mastery >= 0.70) return 3; // Blue
    if (mastery >= 0.50) return 2; // Yellow
    if (mastery >= 0.25) return 1; // Orange
    return 0; // Red
  }
}
