import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/habits_detail/widegts/completion_calendar.dart';
import 'package:habit_tracker/screens/habits_detail/widegts/habit_stats.dart';
import 'package:habit_tracker/screens/habits_detail/widegts/progress_chart.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../add_habits/add_habit_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: habit.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Habit',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddHabitScreen()),
                ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(context);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete_outline, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Delete Habit'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HabitStats(habit: habit),
            const SizedBox(height: 16),
            CompletionCalendar(habit: habit),
            const SizedBox(height: 16),
            ProgressChart(habit: habit),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Delete Habit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            content: Text(
              'Are you sure you want to delete this habit? This action cannot be undone.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Cancel'),
              ),
              TextButton.icon(
                onPressed: () {
                  context.read<HabitProvider>().deleteHabit(habit.id);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
