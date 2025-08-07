import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/statistics/widgets/category_breakdown.dart';
import 'package:habit_tracker/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../services/analytics_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import '../add_habits/add_habit_screen.dart';
import 'widgets/completion_chart.dart';
import 'widgets/streak_display.dart';
import 'widgets/habit_insights.dart';
import 'widgets/overall_stats_card.dart';
import 'widgets/productivity_score.dart';
import 'widgets/time_based_analytics.dart';
import 'widgets/weekly_monthly_progress.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Statistics',
          showBackButton: false,
          bottom: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
              Tab(icon: Icon(Icons.category), text: 'Categories'),
              Tab(icon: Icon(Icons.lightbulb), text: 'Insights'),
            ],
          ),
        ),
        body: Consumer<HabitProvider>(
          builder: (context, habitProvider, child) {
            if (habitProvider.habits.isEmpty) {
              return EmptyState(
                title: 'No Statistics Yet',
                subtitle:
                    'Complete some habits to see your statistics and progress.',
                icon: Icons.analytics,
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
              onRefresh: () async {
                await habitProvider.loadHabits();
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildTrendsTab(),
                  _buildCategoriesTab(),
                  _buildInsightsTab(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2, // Adjust card proportions
                children: [
                  StatCard(
                    title: 'Total Habits',
                    value: '${habitProvider.habits.length}',
                    icon: Icons.task_alt,
                    color: Colors.blue,
                  ),
                  StatCard(
                    title: 'Completed Today',
                    value: '${habitProvider.getCompletedTodayCount()}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  StatCard(
                    title: 'Longest Streak',
                    value: '${habitProvider.getLongestStreak()}',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                  StatCard(
                    title: 'Success Rate',
                    value:
                        '${(habitProvider.getOverallSuccessRate() * 100).toInt()}%',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Productivity Score Section
              ProductivityScoreWidget(), // Fixed: Added const
              const SizedBox(height: 16),

              // Overall Stats Section
              OverallStatsCard(), // Fixed: Added const
              const SizedBox(height: 16),

              // Streak Display Section
              const StreakDisplay(),
              const SizedBox(height: 16),

              // Completion Chart Section
              const CompletionChart(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed widget instantiation
          TimeBasedAnalytics(),
          const SizedBox(height: 16),
          const WeeklyMonthlyProgress(),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryBreakdown(),
          const SizedBox(height: 16),
          _buildCategoryInsights(),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HabitInsights(),
          const SizedBox(height: 16),
          _buildPersonalizedInsights(),
        ],
      ),
    );
  }

  Widget _buildCategoryInsights() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<Map<String, dynamic>>(
      future: _analyticsService.getCategoryAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            color: colorScheme.surface,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Card(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading category insights',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        }

        final categoryAnalytics = snapshot.data!;
        final categoryStats =
            categoryAnalytics['categoryStats'] as Map<String, dynamic>? ?? {};

        if (categoryStats.isEmpty) {
          return Card(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No category insights available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          );
        }

        // Find best and worst performing categories
        final sortedCategories =
            categoryStats.entries.toList()..sort((a, b) {
              final aRate =
                  (a.value as Map<String, dynamic>)['completionRate']
                      as double? ??
                  0.0;
              final bRate =
                  (b.value as Map<String, dynamic>)['completionRate']
                      as double? ??
                  0.0;
              return bRate.compareTo(aRate);
            });

        final bestCategory = sortedCategories.first;
        final worstCategory = sortedCategories.last;

        return Card(
          color: colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Insights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCategoryInsightItem(
                  'Best Performing Category',
                  bestCategory.key,
                  '${(((bestCategory.value as Map<String, dynamic>)['completionRate'] as double) * 100).toStringAsFixed(1)}% success rate',
                  Icons.emoji_events,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                if (sortedCategories.length > 1)
                  _buildCategoryInsightItem(
                    'Needs Attention',
                    worstCategory.key,
                    '${(((worstCategory.value as Map<String, dynamic>)['completionRate'] as double) * 100).toStringAsFixed(1)}% success rate',
                    Icons.trending_down,
                    Colors.orange,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryInsightItem(
    String title,
    String category,
    String description,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  category,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedInsights() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _analyticsService.getHabitInsights(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            color: colorScheme.surface,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 48,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No personalized insights available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Complete more habits to get insights!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final insights = snapshot.data!;

        return Card(
          color: colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalized Insights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ...insights.take(5).map((insight) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getInsightColor(
                          insight['severity'],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getInsightColor(
                            insight['severity'],
                          ).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getInsightIcon(insight['type']),
                                color: _getInsightColor(insight['severity']),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  insight['message'] ?? '',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (insight['suggestion'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              insight['suggestion'],
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getInsightColor(String? severity) {
    switch (severity) {
      case 'positive':
        return Colors.green;
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getInsightIcon(String? type) {
    switch (type) {
      case 'low_completion':
        return Icons.warning;
      case 'high_performance':
        return Icons.star;
      case 'streak_milestone':
        return Icons.local_fire_department;
      case 'best_day':
        return Icons.calendar_today;
      case 'daily_performance':
        return Icons.today;
      default:
        return Icons.lightbulb;
    }
  }
}
