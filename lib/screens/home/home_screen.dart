import 'package:flutter/material.dart';
import 'package:habit_tracker/models/motivational_card/motivation_card.dart';
import 'package:habit_tracker/providers/auth_provider.dart';
import 'package:habit_tracker/screens/authentication_screen/login_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
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
      // context.read<ThemeProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Habit Tracker',
          showBackButton: false,
          actions: [
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
          return const EmptyState(
            title: 'No Habits Yet',
            subtitle:
                'Create your first habit to get started on your journey to better living.',
            icon: Icons.self_improvement,
            actionText: 'Add Habit',
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
                const MotivationCard(),
                const SizedBox(height: 12),

                const ProgressSummary(),
                const SizedBox(height: 12),

                const QuickAddHabit(),
                const SizedBox(height: 16),

                ListView.builder(
                  itemCount: habitProvider.habits.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final habit = habitProvider.habits[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HabitCard(habit: habit),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
