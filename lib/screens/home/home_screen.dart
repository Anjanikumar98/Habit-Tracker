import 'package:flutter/material.dart';
import 'package:habit_tracker/models/motivational_card/motivation_card.dart';
import 'package:habit_tracker/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/stat_card.dart';
import '../add_habits/add_habit_screen.dart';
import '../setting/setting_screen.dart';
import 'widgets/habit_card.dart';
import 'widgets/progress_summary.dart';
import 'widgets/quick_add_habit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
    });
  }

  // Helper method to get user initials
  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    List<String> names = name.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: context.watch<AuthProvider>().getGreeting(),
          showBackButton: false,
          actions: [
            // Profile Avatar in App Bar
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.currentUser;
                return ProfileAvatar(
                  imageUrl: user?.profilePicture,
                  initials: _getInitials(user?.name ?? 'User'),
                  size: 31,
                  onTap: () {
                    setState(() => _currentIndex = 2); // Navigate to Settings
                  },
                );
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Habit',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHabitScreen()),
                );
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            const StatisticsScreen(),
            const SettingsScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          selectedLabelStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: textTheme.labelMedium,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        if (habitProvider.habits.isEmpty) {
          return EmptyState(
            title: 'No Habits Yet',
            subtitle:
                'Create your first habit to get started on your journey to better living.',
            icon: Icons.self_improvement,
            actionText: 'Add Habit',
            onActionPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddHabitScreen()),
              );
            },
          );
        }

        return RefreshIndicator(
          color: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          onRefresh: () => habitProvider.loadHabits(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Stats Section
                _buildQuickStats(),
                const SizedBox(height: 20),

                // Enhanced Motivation Card - Now more prominent
                const MotivationCard(),
                const SizedBox(height: 20),

                // Progress Summary
                const ProgressSummary(),
                const SizedBox(height: 16),

                // Quick Add Habit
                const QuickAddHabit(),
                const SizedBox(height: 20),

                // Section Header for Habits
                if (habitProvider.habits.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Habits',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${habitProvider.habits.length} habit${habitProvider.habits.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Habit Cards
                ...habitProvider.habits.map(
                  (habit) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HabitCard(habit: habit),
                  ),
                ),

                // Bottom spacing for better scrolling experience
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  // Enhanced quick stats section
  Widget _buildQuickStats() {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final completedToday = habitProvider.getCompletedTodayCount();
        final totalHabits = habitProvider.habits.length;
        final currentStreak = habitProvider.getCurrentStreak();
        final completionRate =
            totalHabits > 0 ? (completedToday / totalHabits) : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (totalHabits > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          completionRate >= 1.0
                              ? Colors.green.withOpacity(0.15)
                              : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(completionRate * 100).round()}% Complete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            completionRate >= 1.0
                                ? Colors.green.shade700
                                : colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Completed Today',
                    value: '$completedToday/$totalHabits',
                    icon: Icons.today,
                    color:
                        completedToday == totalHabits && totalHabits > 0
                            ? Colors.green
                            : Colors.blue,
                    onTap: () {
                      // Optional: Navigate to today's habits view
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Current Streak',
                    value: '$currentStreak day${currentStreak != 1 ? 's' : ''}',
                    icon: Icons.local_fire_department,
                    color:
                        currentStreak >= 7
                            ? Colors.orange
                            : currentStreak >= 3
                            ? Colors.amber
                            : Colors.grey,
                    onTap: () {
                      setState(() => _currentIndex = 1); // Go to Statistics
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
