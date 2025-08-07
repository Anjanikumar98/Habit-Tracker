import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/habit.dart';
import '../../../providers/habit_provider.dart';

class HabitStats extends StatelessWidget {
  final Habit habit;

  const HabitStats({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final completionRate = habitProvider.getCompletionRate(habit);
        final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

        return Card(
          color: habit.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habit Statistics',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: onPrimaryColor),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Current Streak', '${habit.currentStreak}'),
                    _buildStatItem('Longest Streak', '${habit.longestStreak}'),
                    _buildStatItem(
                      'Total Completions',
                      '${habit.totalCompletions}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Completion Rate: ${completionRate.toStringAsFixed(1)}%',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: onPrimaryColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

