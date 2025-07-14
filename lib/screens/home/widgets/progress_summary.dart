import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// class ProgressSummary extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HabitProvider>(
//       builder: (context, habitProvider, child) {
//         final totalHabits = habitProvider.habits.length;
//         final completedToday = habitProvider.habits
//             .where((habit) => habit.isCompletedToday)
//             .length;
//         final weeklyCompletion = habitProvider.getWeeklyCompletionRate();
//
//         return Container(
//           margin: const EdgeInsets.all(16),
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xff6f1bff), Color(0xff9c4dff)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildStat('Today', '$completedToday/$totalHabits'),
//                   _buildStat('This Week', '${(weeklyCompletion * 100).toInt()}%'),
//                   _buildStat('Total Habits', '$totalHabits'),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               LinearProgressIndicator(
//                 value: totalHabits > 0 ? completedToday / totalHabits : 0,
//                 backgroundColor: Colors.white30,
//                 valueColor: const AlwaysStoppedAnimation(Colors.white),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 totalHabits > 0
//                     ? 'You\'ve completed ${((completedToday / totalHabits) * 100).toInt()}% of your habits today!'
//                     : 'Add your first habit to get started!',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildStat(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
// }