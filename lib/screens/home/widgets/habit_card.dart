import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/habit.dart';
import '../../../providers/habit_provider.dart';
import '../../../widgets/completion_button.dart';
import '../../../widgets/streak_badge.dart';
import '../../habits_detail/habit_detail_screen.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final isCompleted = habitProvider.isHabitCompletedToday(habit.id as Habit);
        final completionRate = habitProvider.getCompletionRate(habit.id as Habit);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HabitDetailScreen(habit: habit),
                  ),
                ),
            borderRadius: BorderRadius.circular(12),
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
                          // color: Color(
                          //   int.parse(habit.color.substring(1), radix: 16) +
                          //       0xFF000000,
                          // ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (habit.description.isNotEmpty)
                              Text(
                                habit.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      CompletionButton(
                        isCompleted: isCompleted,
                        onPressed: () {
                          if (!isCompleted) {
                            habitProvider.completeHabit(habit.id);
                          }
                        },
                        color: Colors.white24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          StreakBadge(
                            streak: habit.currentStreak,
                            isActive: habit.currentStreak > 0,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(completionRate * 100).toInt()}% complete',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        habit.frequency,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


