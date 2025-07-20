import 'package:flutter/material.dart';
import '../../../services/analytics_service.dart';

class OverallStatsCard extends StatelessWidget {
  final AnalyticsService _analyticsService = AnalyticsService();

  OverallStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _analyticsService.getOverallStats(),
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
              child: Text('Error loading overall statistics'),
            ),
          );
        }

        final stats = snapshot.data!;

        return Card(
          elevation: 3,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.1),
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.dashboard,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Overall Statistics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Main stats grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      context,
                      'Total Habits',
                      stats['totalHabits']?.toString() ?? '0',
                      Icons.list_alt,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      'Active Habits',
                      stats['activeHabits']?.toString() ?? '0',
                      Icons.track_changes,
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'Total Completions',
                      stats['totalCompletions']?.toString() ?? '0',
                      Icons.check_circle,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      'Today\'s Completions',
                      stats['completionsToday']?.toString() ?? '0',
                      Icons.today,
                      Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Success rates
                _buildSuccessRatesSection(context, stats),

                const SizedBox(height: 20),

                // Additional insights
                _buildAdditionalInsights(context, stats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRatesSection(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final overallRate = stats['overallCompletionRate'] as double? ?? 0.0;
    final todayRate = stats['todayCompletionRate'] as double? ?? 0.0;
    final weekRate = stats['weekCompletionRate'] as double? ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Success Rates',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            context,
            'Overall',
            overallRate,
            _getRateColor(overallRate),
          ),
          const SizedBox(height: 12),
          _buildProgressRow(
            context,
            'This Week',
            weekRate,
            _getRateColor(weekRate),
          ),
          const SizedBox(height: 12),
          _buildProgressRow(
            context,
            'Today',
            todayRate,
            _getRateColor(todayRate),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(
    BuildContext context,
    String label,
    double rate,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: rate,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${(rate * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInsights(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final avgDaily = stats['averageDailyCompletions'] as double? ?? 0.0;
    final longestStreak = stats['longestStreak'] as int? ?? 0;
    final daysTracked = stats['totalDaysTracked'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Insights',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInsightItem(
                context,
                'Daily Average',
                avgDaily.toStringAsFixed(1),
                Icons.trending_up,
              ),
              _buildInsightItem(
                context,
                'Best Streak',
                longestStreak.toString(),
                Icons.local_fire_department,
              ),
              _buildInsightItem(
                context,
                'Days Tracked',
                daysTracked.toString(),
                Icons.calendar_today,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getRateColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.6) return Colors.lightGreen;
    if (rate >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
