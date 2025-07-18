import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import 'widgets/completion_chart.dart';
import 'widgets/streak_display.dart';
import 'widgets/habit_insights.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Statistics', showBackButton: false),
        body: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            if (habitProvider.habits.isEmpty) {
              return const EmptyState(
                title: 'No Statistics Yet',
                subtitle:
                    'Complete some habits to see your statistics and progress.',
                icon: Icons.analytics,
                actionText: 'Add Habit',
              );
            }

            return RefreshIndicator(
              onRefresh: () => habitProvider.loadHabits(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(context, habitProvider),
                    const SizedBox(height: 16),
                    const StreakDisplay(),
                    const SizedBox(height: 16),
                    const CompletionChart(),
                    const SizedBox(height: 16),
                    const HabitInsights(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, HabitProvider habitProvider) {
    final totalHabits = habitProvider.habits.length;
    final completedToday =
        habitProvider.habits
            .where(
              (habit) => habit.completedDates.any(
                (date) =>
                    date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day,
              ),
            )
            .length;

    final completionRate =
        totalHabits > 0 ? (completedToday / totalHabits) * 100 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Total Habits',
                  totalHabits.toString(),
                  Icons.list_alt,
                ),
                _buildStatItem(
                  context,
                  'Completed',
                  completedToday.toString(),
                  Icons.check_circle,
                ),
                _buildStatItem(
                  context,
                  'Success Rate',
                  '${completionRate.toStringAsFixed(0)}%',
                  Icons.trending_up,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
