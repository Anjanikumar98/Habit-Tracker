import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/statistics/widgets/category_breakdown.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../services/analytics_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
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
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Statistics',
          showBackButton: false,
          bottom: TabBar(
            controller: _tabController,
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
              return const EmptyState(
                title: 'No Statistics Yet',
                subtitle:
                    'Complete some habits to see your statistics and progress.',
                icon: Icons.analytics,
                actionText: 'Add Habit',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductivityScoreWidget(),
          const SizedBox(height: 16),
          OverallStatsCard(),
          const SizedBox(height: 16),
          const StreakDisplay(),
          const SizedBox(height: 16),
          const CompletionChart(),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _analyticsService.getCategoryAnalytics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Error loading category insights'),
            ),
          );
        }

        final categoryAnalytics = snapshot.data!;
        final categoryStats =
            categoryAnalytics['categoryStats'] as Map<String, dynamic>? ?? {};

        if (categoryStats.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No category insights available'),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Insights',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  category,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedInsights() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _analyticsService.getHabitInsights(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.lightbulb_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No personalized insights available'),
                  Text('Complete more habits to get insights!'),
                ],
              ),
            ),
          );
        }

        final insights = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalized Insights',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          if (insight['suggestion'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              insight['suggestion'],
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
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

