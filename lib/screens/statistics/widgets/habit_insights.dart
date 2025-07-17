import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/habit_provider.dart';
import '../../../models/habit.dart';

class HabitInsights extends StatelessWidget {
  const HabitInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Insights', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                if (habitProvider.habits.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildInsightsList(context, habitProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No insights available',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          Text(
            'Complete some habits to see personalized insights!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsList(BuildContext context, HabitProvider habitProvider) {
    final insights = _generateInsights(habitProvider);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: insights.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final insight = insights[index];
        return _buildInsightCard(context, insight);
      },
    );
  }

  Widget _buildInsightCard(BuildContext context, Map<String, dynamic> insight) {
    final type = insight['type'] as String;
    final title = insight['title'] as String;
    final description = insight['description'] as String;
    final icon = insight['icon'] as IconData;
    final color = insight['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateInsights(HabitProvider habitProvider) {
    final insights = <Map<String, dynamic>>[];
    final habits = habitProvider.habits;

    if (habits.isEmpty) return insights;

    // Best performing habit
    final bestHabit = _findBestPerformingHabit(habits);
    if (bestHabit != null) {
      final completionRate = _calculateCompletionRate(bestHabit);
      insights.add({
        'type': 'best_habit',
        'title': 'Top Performer',
        'description':
            '${bestHabit.name} has a ${completionRate.toStringAsFixed(1)}% completion rate this month!',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
      });
    }

    // Consistency insight
    final consistentHabit = _findMostConsistentHabit(habits);
    if (consistentHabit != null) {
      final streak = _calculateCurrentStreak(consistentHabit);
      insights.add({
        'type': 'consistency',
        'title': 'Consistency Champion',
        'description':
            '${consistentHabit.name} has a ${streak}-day streak! Keep it up!',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      });
    }

    // Improvement opportunity
    final improvementHabit = _findImprovementOpportunity(habits);
    if (improvementHabit != null) {
      insights.add({
        'type': 'improvement',
        'title': 'Room for Growth',
        'description':
            '${improvementHabit.name} needs some attention. Try setting a reminder!',
        'icon': Icons.trending_up,
        'color': Colors.blue,
      });
    }

    // Weekly summary
    final weeklyStats = _calculateWeeklyStats(habits);
    insights.add({
      'type': 'weekly_summary',
      'title': 'This Week\'s Progress',
      'description':
          'You completed ${weeklyStats['completed']} out of ${weeklyStats['total']} habits this week (${weeklyStats['percentage'].toStringAsFixed(1)}%)',
      'icon': Icons.calendar_view_week,
      'color': Colors.green,
    });

    // Motivation boost
    final totalCompletions = habits.fold<int>(
      0,
      (sum, habit) => sum + habit.completedDates.length,
    );

    if (totalCompletions > 0) {
      insights.add({
        'type': 'motivation',
        'title': 'Great Progress!',
        'description':
            'You\'ve completed habits $totalCompletions times. Every step counts towards your goals!',
        'icon': Icons.star,
        'color': Colors.purple,
      });
    }

    return insights;
  }

  Habit? _findBestPerformingHabit(List<Habit> habits) {
    double bestRate = 0;
    Habit? bestHabit;

    for (final habit in habits) {
      final rate = _calculateCompletionRate(habit);
      if (rate > bestRate) {
        bestRate = rate;
        bestHabit = habit;
      }
    }

    return bestRate > 0 ? bestHabit : null;
  }

  Habit? _findMostConsistentHabit(List<Habit> habits) {
    int longestStreak = 0;
    Habit? mostConsistent;

    for (final habit in habits) {
      final streak = _calculateCurrentStreak(habit);
      if (streak > longestStreak) {
        longestStreak = streak;
        mostConsistent = habit;
      }
    }

    return longestStreak > 0 ? mostConsistent : null;
  }

  Habit? _findImprovementOpportunity(List<Habit> habits) {
    double lowestRate = double.infinity;
    Habit? improvementHabit;

    for (final habit in habits) {
      final rate = _calculateCompletionRate(habit);
      if (rate < lowestRate && rate < 50) {
        lowestRate = rate;
        improvementHabit = habit;
      }
    }

    return improvementHabit;
  }

  double _calculateCompletionRate(Habit habit) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    int completedDays = 0;
    int totalDays = 30;

    for (int i = 0; i < 30; i++) {
      final date = thirtyDaysAgo.add(Duration(days: i));
      if (habit.completedDates.any(
        (completedDate) =>
            completedDate.year == date.year &&
            completedDate.month == date.month &&
            completedDate.day == date.day,
      )) {
        completedDays++;
      }
    }

    return totalDays > 0 ? (completedDays / totalDays) * 100 : 0;
  }

  int _calculateCurrentStreak(Habit habit) {
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final isCompleted = habit.completedDates.any(
        (completedDate) =>
            completedDate.year == date.year &&
            completedDate.month == date.month &&
            completedDate.day == date.day,
      );

      if (isCompleted) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Map<String, dynamic> _calculateWeeklyStats(List<Habit> habits) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    int totalPossibleCompletions = 0;
    int actualCompletions = 0;

    for (final habit in habits) {
      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        totalPossibleCompletions++;

        if (habit.completedDates.any(
          (completedDate) =>
              completedDate.year == date.year &&
              completedDate.month == date.month &&
              completedDate.day == date.day,
        )) {
          actualCompletions++;
        }
      }
    }

    final percentage =
        totalPossibleCompletions > 0
            ? (actualCompletions / totalPossibleCompletions) * 100
            : 0.0;

    return {
      'completed': actualCompletions,
      'total': totalPossibleCompletions,
      'percentage': percentage,
    };
  }
}
