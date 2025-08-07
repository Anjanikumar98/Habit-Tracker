import 'package:flutter/material.dart';
import '../../../services/analytics_service.dart';

class CategoryBreakdown extends StatelessWidget {
  final AnalyticsService _analyticsService = AnalyticsService();

  CategoryBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          return Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading category analytics',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.category,
                    size: 48,
                    color: theme.iconTheme.color?.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No category data available',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Calculate total completions
        final totalCompletions = categoryStats.values
            .map(
              (stats) =>
                  (stats as Map<String, dynamic>)['totalCompletions'] as int? ??
                  0,
            )
            .fold<int>(0, (sum, value) => sum + value);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.category, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Category Performance',
                      style: theme.textTheme.titleLarge?.copyWith(
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
                }),
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
    final theme = Theme.of(context);
    final color = _getCategoryColor(categoryName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header: Category name and completion badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Category Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$habitCount ${habitCount == 1 ? 'habit' : 'habits'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              /// Completions Badge
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
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Progress & Share
          Row(
            children: [
              /// Success Rate
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Success Rate', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: completionRate,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(completionRate * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              /// Share of Total
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Share of Total', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
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
    final theme = Theme.of(context);

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
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
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
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
