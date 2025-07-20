import 'package:flutter/material.dart';
import '../../../services/analytics_service.dart';

class WeeklyMonthlyProgress extends StatefulWidget {
  const WeeklyMonthlyProgress({super.key});

  @override
  State<WeeklyMonthlyProgress> createState() => _WeeklyMonthlyProgressState();
}

class _WeeklyMonthlyProgressState extends State<WeeklyMonthlyProgress>
    with TickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();
  late TabController _tabController;

  Map<String, dynamic>? _weeklyData;
  Map<String, dynamic>? _monthlyData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _analyticsService.getWeeklyProgress(),
        _analyticsService.getMonthlyProgress(),
      ]);

      if (mounted) {
        setState(() {
          _weeklyData = results[0];
          _monthlyData = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.view_week), text: 'Weekly'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Monthly'),
            ],
          ),
          SizedBox(
            height: 400,
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildWeeklyProgress(),
                        _buildMonthlyProgress(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress() {
    if (_weeklyData == null) {
      return const Center(child: Text('No weekly data available'));
    }

    final currentWeekData =
        _weeklyData!['currentWeek'] as Map<String, dynamic>? ?? {};
    final previousWeeksData =
        _weeklyData!['previousWeeks'] as List<dynamic>? ?? [];
    final weeklyTrend = _weeklyData!['weeklyTrend'] as double? ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeeklyOverview(currentWeekData, weeklyTrend),
          const SizedBox(height: 20),
          _buildCurrentWeekBreakdown(currentWeekData),
          const SizedBox(height: 20),
          _buildWeeklyTrendChart(previousWeeksData),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgress() {
    if (_monthlyData == null) {
      return const Center(child: Text('No monthly data available'));
    }

    final currentMonthData =
        _monthlyData!['currentMonth'] as Map<String, dynamic>? ?? {};
    final previousMonthsData =
        _monthlyData!['previousMonths'] as List<dynamic>? ?? [];
    final monthlyTrend = _monthlyData!['monthlyTrend'] as double? ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthlyOverview(currentMonthData, monthlyTrend),
          const SizedBox(height: 20),
          _buildCurrentMonthBreakdown(currentMonthData),
          const SizedBox(height: 20),
          _buildMonthlyTrendChart(previousMonthsData),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview(Map<String, dynamic> currentWeek, double trend) {
    final completions = currentWeek['totalCompletions'] as int? ?? 0;
    final completionRate = currentWeek['completionRate'] as double? ?? 0.0;
    final streaks = currentWeek['activeStreaks'] as int? ?? 0;

    return _overviewContainer(
      title: 'This Week',
      trend: trend,
      stats: [
        _buildStatItem(
          'Completions',
          completions.toString(),
          Icons.check_circle,
        ),
        _buildStatItem(
          'Success Rate',
          '${(completionRate * 100).toStringAsFixed(0)}%',
          Icons.trending_up,
        ),
        _buildStatItem(
          'Active Streaks',
          streaks.toString(),
          Icons.local_fire_department,
        ),
      ],
      color: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildMonthlyOverview(
    Map<String, dynamic> currentMonth,
    double trend,
  ) {
    final completions = currentMonth['totalCompletions'] as int? ?? 0;
    final completionRate = currentMonth['completionRate'] as double? ?? 0.0;
    final bestWeek = currentMonth['bestWeek'] as int? ?? 0;

    return _overviewContainer(
      title: 'This Month',
      trend: trend,
      stats: [
        _buildStatItem(
          'Completions',
          completions.toString(),
          Icons.check_circle,
        ),
        _buildStatItem(
          'Success Rate',
          '${(completionRate * 100).toStringAsFixed(0)}%',
          Icons.trending_up,
        ),
        _buildStatItem('Best Week', 'Week $bestWeek', Icons.star),
      ],
      color: Theme.of(context).colorScheme.secondaryContainer,
    );
  }

  Widget _overviewContainer({
    required String title,
    required double trend,
    required List<Widget> stats,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              _buildTrendIndicator(trend),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeekBreakdown(Map<String, dynamic> currentWeek) {
    final dailyData =
        currentWeek['dailyBreakdown'] as Map<String, dynamic>? ?? {};

    if (dailyData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Breakdown (This Week)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...dailyData.entries.map((entry) {
          final day = entry.key;
          final completions = entry.value as int? ?? 0;
          return ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(day),
            trailing: Text('$completions completions'),
          );
        }),
      ],
    );
  }

  Widget _buildCurrentMonthBreakdown(Map<String, dynamic> currentMonth) {
    final weeklyData =
        currentMonth['weeklyBreakdown'] as Map<String, dynamic>? ?? {};

    if (weeklyData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Breakdown (This Month)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...weeklyData.entries.map((entry) {
          final week = entry.key;
          final completions = entry.value as int? ?? 0;
          return ListTile(
            leading: const Icon(Icons.date_range),
            title: Text('Week $week'),
            trailing: Text('$completions completions'),
          );
        }),
      ],
    );
  }

  Widget _buildWeeklyTrendChart(List<dynamic> previousWeeks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Trends',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...previousWeeks.map((weekData) {
          final week = weekData['week'] ?? '';
          final score = weekData['score'] ?? 0;
          return ListTile(
            leading: const Icon(Icons.timeline),
            title: Text('Week $week'),
            trailing: Text('Score: $score'),
          );
        }),
      ],
    );
  }

  Widget _buildMonthlyTrendChart(List<dynamic> previousMonths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Trends',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...previousMonths.map((monthData) {
          final month = monthData['month'] ?? '';
          final score = monthData['score'] ?? 0;
          return ListTile(
            leading: const Icon(Icons.show_chart),
            title: Text('Month $month'),
            trailing: Text('Score: $score'),
          );
        }),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildTrendIndicator(double trend) {
    final icon = trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    final color = trend >= 0 ? Colors.green : Colors.red;
    final text = '${trend.abs().toStringAsFixed(1)}%';

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
