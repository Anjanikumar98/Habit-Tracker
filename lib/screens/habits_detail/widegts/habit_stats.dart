import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/habit.dart';
import '../../../providers/habit_provider.dart';

class HabitStats extends StatelessWidget {
  final Habit habit;

  const HabitStats({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        // final completionRate = habitProvider.getCompletionRate(habit.id);

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // color: Color(
            //   int.parse(habit.color.substring(1), radix: 16) + 0xFF000000,
            // ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Habit Statistics',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // _buildStatItem('Current Streak', '${habit.currentStreak}'),
                  // _buildStatItem('Longest Streak', '${habit.longestStreak}'),
                  // _buildStatItem(
                  //   'Total Completions',
                  //   '${habit.totalCompletions}',
                  // ),
                ],
              ),
              const SizedBox(height: 24),
              // Center(
              //   child: Text(
              //     'Completion Rate: ${completionRate.toStringAsFixed(1)}%',
              //     style: Theme.of(
              //       context,
              //     ).textTheme.bodyLarge?.copyWith(color: Colors.white),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
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
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
