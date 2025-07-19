import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/habit_provider.dart';

class CompletionChart extends StatelessWidget {
  const CompletionChart({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        return Card(
          color:
              Theme.of(context)
                  .colorScheme
                  .surface, // Optional: Ensures proper light/dark support
          elevation:
              2, // Optional: If you want a consistent feel with AppTheme.cardTheme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ), // Match AppTheme card shape
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Completion Trends',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildCompletionChart(context, habitProvider),
                ),
                const SizedBox(height: 16),
                _buildChartLegend(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletionChart(
    BuildContext context,
    HabitProvider habitProvider,
  ) {
    final chartData = _getWeeklyCompletionData(habitProvider);

    if (chartData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(1)}%',
                TextStyle(
                  backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget:
                  (value, meta) => Text(
                    '${value.toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final weekLabels = ['W1', 'W2', 'W3', 'W4'];
                return Text(
                  value.toInt() < weekLabels.length
                      ? weekLabels[value.toInt()]
                      : '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        barGroups:
            chartData.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    color: Theme.of(context).colorScheme.primary,
                    width: 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  List<double> _getWeeklyCompletionData(HabitProvider habitProvider) {
    final now = DateTime.now();
    final weeklyData = <double>[];

    for (int week = 0; week < 4; week++) {
      // Start of the week (Monday)
      final weekStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1 + (week * 7)));

      // End of the week (Sunday)
      final weekEnd = weekStart.add(const Duration(days: 6));

      int totalCompletions = 0;
      int totalPossible = 0;

      for (final habit in habitProvider.habits) {
        for (int i = 0; i < 7; i++) {
          final date = weekStart.add(Duration(days: i));

          // Skip future dates (only count until today)
          if (date.isAfter(now)) continue;

          totalPossible++;

          final completed = habit.completedDates.any(
            (completedDate) =>
                completedDate.year == date.year &&
                completedDate.month == date.month &&
                completedDate.day == date.day,
          );

          if (completed) totalCompletions++;
        }
      }

      final completionRate =
          totalPossible > 0 ? (totalCompletions / totalPossible) * 100 : 0.0;

      weeklyData.add(completionRate);
    }

    return weeklyData.reversed.toList(); // Oldest week first
  }

  Widget _buildChartLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text('Completion Rate', style: Theme.of(context).textTheme.bodySmall),
          const Spacer(),
          Text(
            'Last 4 weeks',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
