import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/habit.dart';
import '../../../providers/habit_provider.dart';
import '../../../widgets/completion_button.dart';
import '../../../widgets/streak_badge.dart';
import '../../../widgets/habit_progress_indicator.dart';
import '../../habits_detail/habit_detail_screen.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final streak = habitProvider.getHabitStreak(habit.id);
        final frequency = habit.frequency;
        final isCompleted = habitProvider.isHabitCompletedToday(habit);

        // Calculate proper completion rate based on habit progress
        final completionRate = habitProvider.getHabitCompletionRate(habit.id);

        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        final colorScheme = theme.colorScheme;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                  // Header row with habit info and completion button
                  Row(
                    children: [
                      // Color indicator
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: habit.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Habit details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (habit.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                habit.description,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Completion button - using the custom widget correctly
                      CompletionButton(
                        isCompleted: isCompleted,
                        color: habit.color, // Use habit's actual color
                        onPressed: () {
                          habitProvider.toggleHabitCompletion(
                            habit.id,
                            DateTime.now(),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress indicator - using the custom widget
                  HabitProgressIndicator(
                    progress: completionRate,
                    color: habit.color,
                    label: 'Progress',
                  ),

                  const SizedBox(height: 12),

                  // Bottom row with streak and frequency
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Streak badge and completion percentage
                      Row(
                        children: [
                          StreakBadge(streak: streak, isActive: streak > 0),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: habit.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: habit.color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${(completionRate * 100).toInt()}%',
                              style: textTheme.labelSmall?.copyWith(
                                color: habit.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Frequency info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          frequency,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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


