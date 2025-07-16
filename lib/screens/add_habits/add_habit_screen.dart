import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'widgets/habit_form.dart';

class AddHabitScreen extends StatelessWidget {
  const AddHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add New Habit'),
      body: const HabitForm(),
    );
  }
}
