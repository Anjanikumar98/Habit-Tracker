import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/home/widgets/habit_card.dart';
import 'package:habit_tracker/screens/home/widgets/progress_summary.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<HabitProvider>(context, listen: false).loadHabits();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Your Habits',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-habit'),
        child: const Icon(Icons.add),
      ),
      // body: Consumer<HabitProvider>(
      //   builder: (context, habitProvider, child) {
      //     if (habitProvider.isLoading) {
      //       return const Center(child: CircularProgressIndicator());
      //     }
      //
      //     if (habitProvider.habits.isEmpty) {
      //       return EmptyState(
      //         title: 'No habits yet!',
      //         subtitle: 'Tap the + button to create your first habit',
      //         icon: Icons.track_changes,
      //       );
      //     }
      //
      //     return Column(
      //       children: [
      //         ProgressSummary(),
      //         const SizedBox(height: 16),
      //         QuickAddHabit(),
      //         const SizedBox(height: 16),
      //         Expanded(
      //           child: ListView.builder(
      //             padding: const EdgeInsets.symmetric(horizontal: 16),
      //             itemCount: habitProvider.habits.length,
      //             itemBuilder: (context, index) {
      //               final habit = habitProvider.habits[index];
      //               return HabitCard(
      //                 habit: habit,
      //                 onTap: () => _navigateToDetail(habit),
      //                 onComplete: () => habitProvider.toggleHabitCompletion(habit.id),
      //               );
      //             },
      //           ),
      //         ),
      //       ],
      //     );
      //   },
      // )
    );
  }

  void _navigateToDetail(habit) {
    Navigator.pushNamed(
      context,
      '/habit-detail',
      arguments: habit,
    );
  }

  void _showSearchDialog() {
    // Implementation for search functionality
  }

  void _showSortDialog() {
    // Implementation for sort functionality
  }
}
