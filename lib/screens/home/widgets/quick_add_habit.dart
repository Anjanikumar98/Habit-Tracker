import 'package:flutter/material.dart';

import '../../add_habits/add_habit_screen.dart';

class QuickAddHabit extends StatelessWidget {
  const QuickAddHabit({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surfaceVariant,
        child: ListTile(
          leading: Icon(Icons.add_circle_outline, color: colorScheme.primary),
          title: Text(
            'Add New Habit',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            'Create a new habit to track',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.outline),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddHabitScreen()),
            );
          },
        ),
      ),
    );
  }
}
