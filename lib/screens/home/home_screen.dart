// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/habit_provider.dart';
// import '../../providers/theme_provider.dart';
// import '../../screens/statistics/statistics_screen.dart';
// import '../../widgets/custom_app_bar.dart';
// import '../../widgets/empty_state.dart';
// import '../add_habits/add_habit_screen.dart';
// import 'widgets/habit_card.dart';
// import 'widgets/progress_summary.dart';
// import 'widgets/quick_add_habit.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<HabitProvider>().loadHabits();
//       context.read<ThemeProvider>().loadSettings();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Habit Tracker',
//         showBackButton: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed:
//                 () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const AddHabitScreen()),
//                 ),
//           ),
//         ],
//       ),
//       body: IndexedStack(
//         index: _currentIndex,
//         children: [
//           _buildHomeTab(),
//           const StatisticsScreen(),
//           const SettingsScreen(),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.analytics),
//             label: 'Statistics',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHomeTab() {
//     return Consumer<HabitProvider>(
//       builder: (context, habitProvider, child) {
//         if (habitProvider.habits.isEmpty) {
//           return const EmptyState(
//             title: 'No Habits Yet',
//             subtitle:
//                 'Create your first habit to get started on your journey to better living.',
//             icon: Icons.self_improvement,
//             actionText: 'Add Habit',
//           );
//         }
//
//         return RefreshIndicator(
//           onRefresh: () => habitProvider.loadHabits(),
//           child: Column(
//             children: [
//               const ProgressSummary(),
//               const QuickAddHabit(),
//               Expanded(
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: habitProvider.habits.length,
//                   itemBuilder: (context, index) {
//                     final habit = habitProvider.habits[index];
//                     return HabitCard(habit: habit);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
