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

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();
  late TabController _tabController;

  Map<String, dynamic>? _overallStats;
  Map<String, dynamic>? _streakAnalytics;
  Map<String, dynamic>? _categoryAnalytics;
  Map<String, dynamic>? _timeBasedAnalytics;
  double? _productivityScore;
  List<Map<String, dynamic>>? _insights;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _analyticsService.getOverallStats(),
        _analyticsService.getStreakAnalytics(),
        _analyticsService.getCategoryAnalytics(),
        _analyticsService.getTimeBasedAnalytics(),
        _analyticsService.getProductivityScore(),
        _analyticsService.getHabitInsights(),
      ]);

      if (mounted) {
        setState(() {
          _overallStats = results[0] as Map<String, dynamic>;
          _streakAnalytics = results[1] as Map<String, dynamic>;
          _categoryAnalytics = results[2] as Map<String, dynamic>;
          _timeBasedAnalytics = results[3] as Map<String, dynamic>;
          _productivityScore = results[4] as double;
          _insights = results[5] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading analytics: $e')));
      }
    }
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

            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  habitProvider.loadHabits(),
                  _loadAnalytics(),
                ]);
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
          _buildProductivityScoreCard(),
          const SizedBox(height: 16),
          _buildOverallStatsCard(),
          const SizedBox(height: 16),
          _buildStreakOverview(),
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
          _buildTimeBasedAnalytics(),
          const SizedBox(height: 16),
          _buildWeeklyProgress(),
          const SizedBox(height: 16),
          _buildMonthlyProgress(),
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
          _buildCategoryBreakdown(),
          const SizedBox(height: 16),
          _buildCategoryPerformance(),
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

  Widget _buildProductivityScoreCard() {
    if (_productivityScore == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Productivity Score',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _productivityScore! / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(_productivityScore!),
                    ),
                  ),
                ),
                Text(
                  '${_productivityScore!.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(_productivityScore!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getScoreDescription(_productivityScore!),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard() {
    if (_overallStats == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Habits',
                  _overallStats!['totalHabits'].toString(),
                  Icons.list_alt,
                ),
                _buildStatItem(
                  'Active Habits',
                  _overallStats!['activeHabits'].toString(),
                  Icons.track_changes,
                ),
                _buildStatItem(
                  'Total Completions',
                  _overallStats!['totalCompletions'].toString(),
                  Icons.check_circle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Today',
                  _overallStats!['completionsToday'].toString(),
                  Icons.today,
                ),
                _buildStatItem(
                  'Success Rate',
                  '${(_overallStats!['overallCompletionRate'] * 100).toStringAsFixed(0)}%',
                  Icons.trending_up,
                ),
                _buildStatItem(
                  'Today\'s Rate',
                  '${(_overallStats!['todayCompletionRate'] * 100).toStringAsFixed(0)}%',
                  Icons.speed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakOverview() {
    if (_streakAnalytics == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Streak Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Longest Streak',
                  _streakAnalytics!['longestOverallStreak'].toString(),
                  Icons.local_fire_department,
                ),
                _buildStatItem(
                  'Active Streaks',
                  _streakAnalytics!['totalActiveStreaks'].toString(),
                  Icons.whatshot,
                ),
              ],
            ),
            if (_streakAnalytics!['longestStreakHabit'] != null) ...[
              const SizedBox(height: 16),
              Text(
                'Best Habit: ${_streakAnalytics!['longestStreakHabit']}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBasedAnalytics() {
    if (_timeBasedAnalytics == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Peak Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_timeBasedAnalytics!['mostProductiveHour'] != null)
              _buildInsightRow(
                'Most Productive Hour',
                '${_timeBasedAnalytics!['mostProductiveHour']}:00',
                Icons.access_time,
              ),
            if (_timeBasedAnalytics!['mostProductiveDayOfWeek'] != null)
              _buildInsightRow(
                'Best Day of Week',
                _getDayName(_timeBasedAnalytics!['mostProductiveDayOfWeek']),
                Icons.calendar_today,
              ),
            if (_timeBasedAnalytics!['mostProductiveMonth'] != null)
              _buildInsightRow(
                'Best Month',
                _getMonthName(_timeBasedAnalytics!['mostProductiveMonth']),
                Icons.calendar_month,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    if (_categoryAnalytics == null) return const SizedBox.shrink();

    final categoryStats =
        _categoryAnalytics!['categoryStats'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CategoryBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedInsights() {
    if (_insights == null || _insights!.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalized Insights',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._insights!.take(5).map((insight) {
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
  }

  // Placeholder widgets for future implementation
  Widget _buildWeeklyProgress() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Progress'),
            SizedBox(height: 16),
            Text('Weekly progress chart will be implemented here'),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyProgress() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Progress'),
            SizedBox(height: 16),
            Text('Monthly progress chart will be implemented here'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformance() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Performance Chart'),
            SizedBox(height: 16),
            Text('Category performance visualization will be implemented here'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInsightRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.yellow[700]!;
    return Colors.red;
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return 'Excellent! You\'re crushing your goals!';
    if (score >= 60) return 'Great work! Keep up the momentum!';
    if (score >= 40) return 'Good progress! Room for improvement.';
    return 'Let\'s work on building consistency!';
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

  String _getDayName(int dayOfWeek) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[dayOfWeek - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
