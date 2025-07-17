import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/habit_provider.dart';
import '../../../models/habit.dart';

class StreakDisplay extends StatelessWidget {
  const StreakDisplay({super.key});

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
                Text('Streaks', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                if (habitProvider.habits.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildStreaksList(context, habitProvider),
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
            Icons.local_fire_department_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No streaks to display',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          Text(
            'Start completing habits to build streaks!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksList(BuildContext context, HabitProvider habitProvider) {
    final habitsWithStreaks =
        habitProvider.habits
            .map((habit) => MapEntry(habit, _calculateStreak(habit)))
            .toList();

    // Sort by current streak (descending)
    habitsWithStreaks.sort(
      (a, b) => b.value['current']!.compareTo(a.value['current'] as num),
    );

    return Column(
      children: [
        _buildOverallStats(context, habitsWithStreaks),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: habitsWithStreaks.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final entry = habitsWithStreaks[index];
            final habit = entry.key;
            final streakData = entry.value;

            return _buildStreakItem(context, habit, streakData);
          },
        ),
      ],
    );
  }

  Widget _buildOverallStats(
    BuildContext context,
    List<MapEntry<Habit, Map<String, int>>> habitsWithStreaks,
  ) {
    final totalCurrentStreak = habitsWithStreaks.fold<int>(
      0,
      (sum, entry) => sum + entry.value['current']!,
    );

    final bestStreak = habitsWithStreaks.fold<int>(
      0,
      (max, entry) => entry.value['best']! > max ? entry.value['best']! : max,
    );

    final activeStreaks =
        habitsWithStreaks.where((entry) => entry.value['current']! > 0).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'Active Streaks',
            activeStreaks.toString(),
            Icons.local_fire_department,
            Theme.of(context).colorScheme.primary,
          ),
          _buildStatItem(
            context,
            'Total Days',
            totalCurrentStreak.toString(),
            Icons.calendar_today,
            Theme.of(context).colorScheme.secondary,
          ),
          _buildStatItem(
            context,
            'Best Streak',
            bestStreak.toString(),
            Icons.emoji_events,
            Theme.of(context).colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStreakItem(
    BuildContext context,
    Habit habit,
    Map<String, int> streakData,
  ) {
    final currentStreak = streakData['current']!;
    final bestStreak = streakData['best']!;
    final isActive = currentStreak > 0;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: habit.color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(habit.priorityIcon, color: habit.color, size: 24),
      ),
      title: Text(habit.name, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isActive
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                size: 16,
                color:
                    isActive
                        ? Colors.orange
                        : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'Current: $currentStreak days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      isActive
                          ? Colors.orange
                          : Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'Best: $bestStreak days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Broken',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, int> _calculateStreak(Habit habit) {
    if (habit.completedDates.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    // Sort dates in descending order
    final sortedDates =
        habit.completedDates.toList()..sort((a, b) => b.compareTo(a));

    int currentStreak = 0;
    int bestStreak = 0;
    int tempStreak = 0;

    final today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    // Calculate current streak
    for (int i = 0; i < 365; i++) {
      final hasCompletion = sortedDates.any(
        (date) =>
            date.year == checkDate.year &&
            date.month == checkDate.month &&
            date.day == checkDate.day,
      );

      if (hasCompletion) {
        if (i == 0 || currentStreak > 0) {
          currentStreak++;
        }
        tempStreak++;
      } else {
        if (i == 0) {
          // Today not completed, current streak is 0
          currentStreak = 0;
        }
        if (tempStreak > bestStreak) {
          bestStreak = tempStreak;
        }
        tempStreak = 0;
      }

      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Check if tempStreak is the best
    if (tempStreak > bestStreak) {
      bestStreak = tempStreak;
    }

    return {'current': currentStreak, 'best': bestStreak};
  }
}
