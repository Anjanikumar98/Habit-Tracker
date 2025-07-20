import 'package:flutter/material.dart';
import '../../../services/analytics_service.dart';

class CategoryBreakdown extends StatelessWidget {
  final AnalyticsService _analyticsService = AnalyticsService();

  CategoryBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Text('Error loading category analytics'),
            ),
          );
        }

        final categoryAnalytics = snapshot.data!;
        final categoryStats =
            categoryAnalytics['categoryStats'] as Map<String, dynamic>? ?? {};

        if (categoryStats.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.category, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No category data available',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        // Calculate total completions for percentage calculations
        final totalCompletions = categoryStats.values
            .map(
              (stats) =>
                  (stats as Map<String, dynamic>)['totalCompletions'] as int? ??
                  0,
            )
            .fold<int>(0, (sum, completions) => sum + completions);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Category Performance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...categoryStats.entries.map((entry) {
                  final categoryName = entry.key;
                  final stats = entry.value as Map<String, dynamic>;
                  final completions = stats['totalCompletions'] as int? ?? 0;
                  final habitCount = stats['habitCount'] as int? ?? 0;
                  final completionRate =
                      stats['completionRate'] as double? ?? 0.0;
                  final percentage =
                      totalCompletions > 0
                          ? (completions / totalCompletions) * 100
                          : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCategoryItem(
                      context,
                      categoryName,
                      completions,
                      habitCount,
                      completionRate,
                      percentage,
                    ),
                  );
                }).toList(),
                if (categoryStats.length > 1) ...[
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildCategorySummary(
                    context,
                    categoryStats,
                    totalCompletions,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String categoryName,
    int completions,
    int habitCount,
    double completionRate,
    double percentage,
  ) {
    final color = _getCategoryColor(categoryName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$habitCount ${habitCount == 1 ? 'habit' : 'habits'}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Success Rate',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: completionRate,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(completionRate * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Share of Total',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySummary(
    BuildContext context,
    Map<String, dynamic> categoryStats,
    int totalCompletions,
  ) {
    final totalHabits = categoryStats.values
        .map(
          (stats) => (stats as Map<String, dynamic>)['habitCount'] as int? ?? 0,
        )
        .fold<int>(0, (sum, habits) => sum + habits);

    final bestCategory = categoryStats.entries.reduce((a, b) {
      final aCompletions =
          (a.value as Map<String, dynamic>)['totalCompletions'] as int? ?? 0;
      final bCompletions =
          (b.value as Map<String, dynamic>)['totalCompletions'] as int? ?? 0;
      return aCompletions > bCompletions ? a : b;
    });

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            'Total Categories',
            categoryStats.length.toString(),
            Icons.category,
          ),
          _buildSummaryItem(
            context,
            'Total Habits',
            totalHabits.toString(),
            Icons.list_alt,
          ),
          _buildSummaryItem(
            context,
            'Best Category',
            bestCategory.key,
            Icons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    // Generate consistent colors for categories
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];

    final index = category.hashCode % colors.length;
    return colors[index.abs()];
  }
}
