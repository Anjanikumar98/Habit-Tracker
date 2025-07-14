import 'package:flutter/material.dart';
import '../../../models/habit.dart';
import '../../../widgets/completion_button.dart';
import '../../../widgets/habit_progress_indicator.dart';
import '../../../widgets/streak_badge.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const HabitCard({
    Key? key,
    required this.habit,
    required this.onTap,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: habit.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          habit.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreakBadge(streak: habit.currentStreak),
                  const SizedBox(width: 8),
                  CompletionButton(
                    isCompleted: habit.isCompletedToday,
                    color: habit.color,
                    onPressed: onComplete,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              HabitProgressIndicator(
                progress: habit.weeklyProgress,
                color: habit.color,
                label: '${habit.completedThisWeek} of ${habit.weeklyGoal} this week',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

