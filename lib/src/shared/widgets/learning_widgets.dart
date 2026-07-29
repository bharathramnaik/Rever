import 'package:flutter/material.dart';

/// Widget showing a 7-day streak calendar
class StreakCalendar extends StatelessWidget {
  final int currentStreak;
  final Set<int> activeDays; // 0=Mon..6=Sun, days with activity this week

  const StreakCalendar({
    super.key,
    required this.currentStreak,
    this.activeDays = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1; // 0-indexed

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  color: currentStreak > 0 ? Colors.orange : Colors.grey),
              const SizedBox(width: 8),
              Text('$currentStreak day streak',
                  style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final isActive = activeDays.contains(i);
              final isToday = i == today;
              return Column(
                children: [
                  Text(dayLabels[i], style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.orange
                          : isToday
                              ? theme.colorScheme.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                      border: isToday && !isActive
                          ? Border.all(color: theme.colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: isActive
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Widget showing daily goal progress ring
class DailyGoalRing extends StatelessWidget {
  final int completed;
  final int goal;
  final String label;

  const DailyGoalRing({
    super.key,
    required this.completed,
    required this.goal,
    this.label = 'Daily Goal',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal > 0 ? (completed / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                  color: progress >= 1.0 ? Colors.green : theme.colorScheme.primary,
                ),
                Center(
                  child: Text(
                    '$completed/$goal',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleMedium),
                Text(
                  progress >= 1.0
                      ? 'Goal reached! 🎉'
                      : '${goal - completed} more to go',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mastery progress bar with tier label
class MasteryProgressBar extends StatelessWidget {
  final double mastery; // 0.0 - 1.0
  final String? conceptTitle;

  const MasteryProgressBar({
    super.key,
    required this.mastery,
    this.conceptTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = _masteryTier(mastery);
    final color = _masteryColor(mastery);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (conceptTitle != null)
              Expanded(
                child: Text(conceptTitle!,
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis),
              ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(tier,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: mastery,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
          ),
        ),
      ],
    );
  }

  String _masteryTier(double m) {
    if (m >= 0.90) return 'Mastered';
    if (m >= 0.70) return 'Proficient';
    if (m >= 0.50) return 'Developing';
    if (m >= 0.25) return 'Familiar';
    return 'Novice';
  }

  Color _masteryColor(double m) {
    if (m >= 0.90) return const Color(0xFF00D9A6);
    if (m >= 0.70) return const Color(0xFF4A90D9);
    if (m >= 0.50) return const Color(0xFFFFC107);
    if (m >= 0.25) return const Color(0xFFFF8C42);
    return const Color(0xFFFF6B6B);
  }
}
