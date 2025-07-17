import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/habit.dart';

class ProgressChart extends StatefulWidget {
  final Habit habit;

  const ProgressChart({Key? key, required this.habit}) : super(key: key);

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year
  final List<String> _periods = ['Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress Chart',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SegmentedButton<int>(
                  segments:
                      _periods
                          .asMap()
                          .entries
                          .map(
                            (entry) => ButtonSegment<int>(
                              value: entry.key,
                              label: Text(entry.value),
                            ),
                          )
                          .toList(),
                  selected: {_selectedPeriod},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _selectedPeriod = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(height: 300, child: _buildChart()),
            const SizedBox(height: 16),
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (_selectedPeriod) {
      case 0:
        return _buildWeekChart();
      case 1:
        return _buildMonthChart();
      case 2:
        return _buildYearChart();
      default:
        return _buildWeekChart();
    }
  }

  Widget _buildWeekChart() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekData = <FlSpot>[];

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final isCompleted = widget.habit.completedDates.any(
        (date) =>
            date.year == day.year &&
            date.month == day.month &&
            date.day == day.day,
      );
      weekData.add(FlSpot(i.toDouble(), isCompleted ? 1.0 : 0.0));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 0.5,
          verticalInterval: 1,
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
              ),
          getDrawingVerticalLine:
              (value) => FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
              ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value == 0 ? 'Miss' : 'Done',
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
                final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Text(
                  dayNames[value.toInt()],
                  style: Theme.of(context).textTheme.bodySmall,
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
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: weekData,
            isCurved: false,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color:
                      spot.y == 1.0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthChart() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthData = <FlSpot>[];

    // Group by weeks
    for (int week = 0; week < 5; week++) {
      int completedDays = 0;
      int totalDays = 0;

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(now.year, now.month, day);
        final weekOfMonth = ((day - 1) / 7).floor();

        if (weekOfMonth == week) {
          totalDays++;
          if (widget.habit.completedDates.any(
            (completedDate) =>
                completedDate.year == date.year &&
                completedDate.month == date.month &&
                completedDate.day == date.day,
          )) {
            completedDays++;
          }
        }
      }

      if (totalDays > 0) {
        monthData.add(FlSpot(week.toDouble(), completedDays / totalDays));
      }
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 0.25,
          verticalInterval: 1,
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
              ),
          getDrawingVerticalLine:
              (value) => FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
              ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value * 100).toInt()}%',
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
                return Text(
                  'W${value.toInt() + 1}',
                  style: Theme.of(context).textTheme.bodySmall,
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
        minX: 0,
        maxX: 4,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: monthData,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearChart() {
    final now = DateTime.now();
    final yearData = <FlSpot>[];

    for (int month = 1; month <= 12; month++) {
      final monthEnd = DateTime(now.year, month + 1, 0);
      int completedDays = 0;
      int totalDays = monthEnd.day;

      for (int day = 1; day <= totalDays; day++) {
        final date = DateTime(now.year, month, day);
        if (widget.habit.completedDates.any(
          (completedDate) =>
              completedDate.year == date.year &&
              completedDate.month == date.month &&
              completedDate.day == date.day,
        )) {
          completedDays++;
        }
      }

      yearData.add(FlSpot((month - 1).toDouble(), completedDays / totalDays));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 0.25,
          verticalInterval: 2,
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
              ),
          getDrawingVerticalLine:
              (value) => FlLine(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                strokeWidth: 1,
              ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value * 100).toInt()}%',
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
                const months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec',
                ];
                return Text(
                  months[value.toInt()],
                  style: Theme.of(context).textTheme.bodySmall,
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
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: yearData,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Completed', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 24),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Missed', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getPeriodDescription(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodDescription() {
    switch (_selectedPeriod) {
      case 0:
        return 'Shows daily completion for the current week';
      case 1:
        return 'Shows weekly completion rate for the current month';
      case 2:
        return 'Shows monthly completion rate for the current year';
      default:
        return '';
    }
  }
}


