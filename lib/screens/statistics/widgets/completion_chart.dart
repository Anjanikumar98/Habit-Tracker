import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/habit_provider.dart';

class CompletionChart extends StatelessWidget {
  const CompletionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Completion Trends',
                  style: Theme.of(context).textTheme.titleLarge,
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
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final weekLabels = ['W1', 'W2', 'W3', 'W4'];
                if (value.toInt() < weekLabels.length) {
                  return Text(
                    weekLabels[value.toInt()],
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return const Text('');
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
            chartData
                .asMap()
                .entries
                .map(
                  (entry) => BarChartGroupData(
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
                  ),
                )
                .toList(),
      ),
    );
  }

  List<double> _getWeeklyCompletionData(HabitProvider habitProvider) {
    final now = DateTime.now();
    final weeklyData = <double>[];

    for (int week = 0; week < 4; week++) {
      final weekStart = now.subtract(
        Duration(days: now.weekday - 1 + (week * 7)),
      );
      int totalCompletions = 0;
      int totalPossible = 0;

      for (final habit in habitProvider.habits) {
        for (int day = 0; day < 7; day++) {
          final date = weekStart.add(Duration(days: day));
          if (date.isBefore(now.add(const Duration(days: 1)))) {
            totalPossible++;
            if (habit.completedDates.any(
              (completedDate) =>
                  completedDate.year == date.year &&
                  completedDate.month == date.month &&
                  completedDate.day == date.day,
            )) {
              totalCompletions++;
            }
          }
        }
      }

      final completionRate =
          totalPossible > 0 ? (totalCompletions / totalPossible) * 100 : 0.0;
      weeklyData.add(completionRate);
    }

    return weeklyData.reversed.toList();
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
