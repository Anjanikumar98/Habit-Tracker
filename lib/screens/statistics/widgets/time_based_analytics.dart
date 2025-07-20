import 'package:flutter/material.dart';
import '../../../services/analytics_service.dart';

class TimeBasedAnalytics extends StatelessWidget {
  final AnalyticsService _analyticsService = AnalyticsService();

  TimeBasedAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _analyticsService.getTimeBasedAnalytics(),
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
              child: Text('Error loading time-based analytics'),
            ),
          );
        }

        final timeAnalytics = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Peak Performance Times',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTimeInsights(context, timeAnalytics),
                const SizedBox(height: 20),
                _buildHourlyBreakdown(context, timeAnalytics),
                const SizedBox(height: 20),
                _buildWeeklyBreakdown(context, timeAnalytics),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeInsights(
    BuildContext context,
    Map<String, dynamic> timeAnalytics,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (timeAnalytics['mostProductiveHour'] != null)
            _buildInsightRow(
              context,
              'Most Productive Hour',
              '${timeAnalytics['mostProductiveHour']}:00',
              Icons.access_time,
              'You complete the most habits around this time',
            ),
          if (timeAnalytics['mostProductiveDayOfWeek'] != null)
            _buildInsightRow(
              context,
              'Best Day of Week',
              _getDayName(timeAnalytics['mostProductiveDayOfWeek']),
              Icons.calendar_today,
              'This day shows your highest completion rate',
            ),
          if (timeAnalytics['mostProductiveMonth'] != null)
            _buildInsightRow(
              context,
              'Best Month',
              _getMonthName(timeAnalytics['mostProductiveMonth']),
              Icons.calendar_month,
              'Your most consistent month historically',
            ),
          if (timeAnalytics['leastProductiveHour'] != null)
            _buildInsightRow(
              context,
              'Challenging Hour',
              '${timeAnalytics['leastProductiveHour']}:00',
              Icons.access_time_filled,
              'Consider adjusting habits scheduled at this time',
              isNegative: true,
            ),
        ],
      ),
    );
  }

  Widget _buildHourlyBreakdown(
    BuildContext context,
    Map<String, dynamic> timeAnalytics,
  ) {
    final hourlyData =
        timeAnalytics['hourlyBreakdown'] as Map<String, dynamic>? ?? {};

    if (hourlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert to list and sort by hour
    final hourlyList =
        hourlyData.entries
            .map(
              (e) => {'hour': int.parse(e.key), 'completions': e.value as int},
            )
            .toList()
          ..sort((a, b) => a['hour']!.compareTo(b['hour'] as num));

    final maxCompletions = hourlyList
        .map((e) => e['completions'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Activity',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyList.length,
            itemBuilder: (context, index) {
              final data = hourlyList[index];
              final hour = data['hour'] as int;
              final completions = data['completions'] as int;
              final height =
                  maxCompletions > 0
                      ? (completions / maxCompletions) * 40
                      : 0.0;

              return Container(
                width: 32,
                margin: const EdgeInsets.only(right: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: _getHourColor(hour),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hour}h',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyBreakdown(
    BuildContext context,
    Map<String, dynamic> timeAnalytics,
  ) {
    final weeklyData =
        timeAnalytics['weeklyBreakdown'] as Map<String, dynamic>? ?? {};

    if (weeklyData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Pattern',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...weeklyData.entries.map((entry) {
          final dayOfWeek = int.parse(entry.key);
          final completions = entry.value as int;
          final maxWeeklyCompletions = weeklyData.values
              .map((v) => v as int)
              .reduce((a, b) => a > b ? a : b);
          final percentage =
              maxWeeklyCompletions > 0
                  ? completions / maxWeeklyCompletions
                  : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    _getDayName(dayOfWeek),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getDayColor(dayOfWeek),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$completions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getDayColor(dayOfWeek),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInsightRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    String description, {
    bool isNegative = false,
  }) {
    final color =
        isNegative ? Colors.orange : Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHourColor(int hour) {
    if (hour >= 6 && hour < 12) return Colors.orange; // Morning
    if (hour >= 12 && hour < 18) return Colors.blue; // Afternoon
    if (hour >= 18 && hour < 22) return Colors.green; // Evening
    return Colors.indigo; // Night/Late
  }

  Color _getDayColor(int dayOfWeek) {
    final colors = [
      Colors.red, // Monday
      Colors.orange, // Tuesday
      Colors.yellow, // Wednesday
      Colors.green, // Thursday
      Colors.blue, // Friday
      Colors.indigo, // Saturday
      Colors.purple, // Sunday
    ];
    return colors[dayOfWeek - 1];
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
