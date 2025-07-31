import 'dart:math';
import 'database_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;

  // Cache frequently accessed data
  Map<String, dynamic>? _cachedStats;
  DateTime? _lastCacheUpdate;

  AnalyticsService._internal();

  final DatabaseService _databaseService = DatabaseService();

  // Overall Statistics
  Future<Map<String, dynamic>> getOverallStats() async {
    final totalHabits = await _databaseService.getTotalHabits();
    final totalCompletions = await _databaseService.getTotalCompletions();
    final completionsToday = await _databaseService.getCompletionsToday();
    final habits = await _databaseService.getHabits();

    final activeHabits = habits.where((h) => h.isActive).length;
    final completionRate =
        totalHabits > 0 ? (totalCompletions / totalHabits) : 0.0;
    final todayCompletionRate =
        activeHabits > 0 ? (completionsToday / activeHabits) : 0.0;

    return {
      'totalHabits': totalHabits,
      'activeHabits': activeHabits,
      'totalCompletions': totalCompletions,
      'completionsToday': completionsToday,
      'overallCompletionRate': completionRate,
      'todayCompletionRate': todayCompletionRate,
    };
  }

  // Streak Analytics
  Future<Map<String, dynamic>> getStreakAnalytics() async {
    final habits = await _databaseService.getHabits();
    final List<Map<String, dynamic>> streakBreakdown = [];

    int longestStreak = 0;
    int totalActiveStreaks = 0;
    String longestStreakHabit = '';

    for (final habit in habits) {
      if (!habit.isActive) continue;

      final int currentStreak = await getCurrentStreak(habit.id);
      final int longestHabitStreak = await getLongestStreak(habit.id);

      if (currentStreak > 0) {
        totalActiveStreaks++;
      }

      if (longestHabitStreak > longestStreak) {
        longestStreak = longestHabitStreak;
        longestStreakHabit = habit.name;
      }

      streakBreakdown.add({
        'habitId': habit.id,
        'habitName': habit.name,
        'currentStreak': currentStreak,
        'longestStreak': longestHabitStreak,
        'category': habit.category,
      });
    }

    streakBreakdown.sort(
      (a, b) =>
          (b['currentStreak'] as int).compareTo(a['currentStreak'] as int),
    );

    final double totalCurrentStreak = streakBreakdown
        .where((s) => (s['currentStreak'] as int) > 0)
        .fold(0.0, (sum, s) => sum + (s['currentStreak'] as num));

    final double averageActiveStreak =
        totalActiveStreaks > 0 ? totalCurrentStreak / totalActiveStreaks : 0.0;

    return {
      'longestOverallStreak': longestStreak,
      'longestStreakHabit': longestStreakHabit,
      'totalActiveStreaks': totalActiveStreaks,
      'averageActiveStreak': averageActiveStreak,
      'streakBreakdown': streakBreakdown,
    };
  }

  // Get current streak for a specific habit
  Future<int> getCurrentStreak(String habitId) async {
    final completions = await _databaseService.getCompletionsByHabit(habitId);
    if (completions.isEmpty) return 0;

    completions.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final completion in completions) {
      final completionDate = DateTime.parse(completion.date as String);
      final daysDiff = currentDate.difference(completionDate).inDays;

      if (daysDiff == streak && completion.isCompleted) {
        streak++;
        currentDate = completionDate;
      } else if (daysDiff > streak) {
        break;
      }
    }

    return streak;
  }

  // Get longest streak for a specific habit
  Future<int> getLongestStreak(String habitId) async {
    final completions = await _databaseService.getCompletionsByHabit(habitId);
    if (completions.isEmpty) return 0;

    completions.sort((a, b) => a.date.compareTo(b.date));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastCompletionDate;

    for (final completion in completions) {
      if (!completion.isCompleted) {
        currentStreak = 0;
        lastCompletionDate = null;
        continue;
      }

      final completionDate = DateTime.parse(completion.date as String);

      if (lastCompletionDate == null) {
        currentStreak = 1;
      } else {
        final daysDiff = completionDate.difference(lastCompletionDate).inDays;
        if (daysDiff == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }

      longestStreak = max(longestStreak, currentStreak);
      lastCompletionDate = completionDate;
    }

    return longestStreak;
  }

  // Weekly Progress Analytics
  Future<Map<String, dynamic>> getWeeklyProgress() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final completions = await _databaseService.getCompletionsByDateRange(
      startOfWeek,
      endOfWeek,
    );

    final habits = await _databaseService.getHabits();
    final activeHabits = habits.where((h) => h.isActive).toList();

    final dailyProgress = <String, Map<String, dynamic>>{};

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];

      // final dayCompletions =
      //     completions
      //         .where((c) => c.date.startsWith(dateStr) && c.isCompleted)
      //         .length;

      // dailyProgress[dateStr] = {
      //   'date': date,
      //   'completions': dayCompletions,
      //   'totalHabits': activeHabits.length,
      //   'completionRate':
      //       activeHabits.isNotEmpty
      //           ? dayCompletions / activeHabits.length
      //           : 0.0,
      // };
    }

    final weeklyCompletions = completions.where((c) => c.isCompleted).length;
    final totalPossibleCompletions = activeHabits.length * 7;

    return {
      'dailyProgress': dailyProgress,
      'weeklyCompletions': weeklyCompletions,
      'totalPossibleCompletions': totalPossibleCompletions,
      'weeklyCompletionRate':
          totalPossibleCompletions > 0
              ? weeklyCompletions / totalPossibleCompletions
              : 0.0,
      'startDate': startOfWeek,
      'endDate': endOfWeek,
    };
  }

  // Monthly Progress Analytics
  Future<Map<String, dynamic>> getMonthlyProgress() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final completions = await _databaseService.getCompletionsByDateRange(
      startOfMonth,
      endOfMonth,
    );

    final habits = await _databaseService.getHabits();
    final activeHabits = habits.where((h) => h.isActive).toList();

    final dailyProgress = <String, Map<String, dynamic>>{};

    for (int day = 1; day <= endOfMonth.day; day++) {
      final date = DateTime(now.year, now.month, day);
      final dateStr = date.toIso8601String().split('T')[0];

      // final dayCompletions =
      //     completions
      //         .where((c) => c.date.startsWith(dateStr) && c.isCompleted)
      //         .length;

      // dailyProgress[dateStr] = {
      //   'date': date,
      //   'completions': dayCompletions,
      //   'totalHabits': activeHabits.length,
      //   'completionRate':
      //       activeHabits.isNotEmpty
      //           ? dayCompletions / activeHabits.length
      //           : 0.0,
      // };
    }

    final monthlyCompletions = completions.where((c) => c.isCompleted).length;
    final totalPossibleCompletions = activeHabits.length * endOfMonth.day;

    return {
      'dailyProgress': dailyProgress,
      'monthlyCompletions': monthlyCompletions,
      'totalPossibleCompletions': totalPossibleCompletions,
      'monthlyCompletionRate':
          totalPossibleCompletions > 0
              ? monthlyCompletions / totalPossibleCompletions
              : 0.0,
      'startDate': startOfMonth,
      'endDate': endOfMonth,
    };
  }

  // Category Analytics
  Future<Map<String, dynamic>> getCategoryAnalytics() async {
    final habits = await _databaseService.getHabits();
    final completionsByCategory =
        await _databaseService.getCompletionsByCategory();

    final categoryStats = <String, Map<String, dynamic>>{};

    for (final habit in habits) {
      if (!habit.isActive) continue;

      final category = habit.category;
      if (!categoryStats.containsKey(category)) {
        categoryStats[category] = {
          'habitCount': 0,
          'totalCompletions': 0,
          'habits': <Map<String, dynamic>>[],
        };
      }

      categoryStats[category]!['habitCount']++;
      categoryStats[category]!['totalCompletions'] +=
          completionsByCategory[category] ?? 0;

      final habitCompletions = await _databaseService.getCompletionsByHabit(
        habit.id,
      );
      final completedCount =
          habitCompletions.where((c) => c.isCompleted).length;

      (categoryStats[category]!['habits'] as List).add({
        'id': habit.id,
        'name': habit.name,
        'completions': completedCount,
        'currentStreak': await getCurrentStreak(habit.id),
      });
    }

    // Sort categories by total completions
    final sortedCategories =
        categoryStats.entries.toList()..sort(
          (a, b) => b.value['totalCompletions'].compareTo(
            a.value['totalCompletions'],
          ),
        );

    return {
      'categoryStats': Map.fromEntries(sortedCategories),
      'totalCategories': categoryStats.length,
      'mostActiveCategory':
          sortedCategories.isNotEmpty ? sortedCategories.first.key : null,
    };
  }

  // Habit Performance Analytics
  Future<Map<String, dynamic>> getHabitPerformance(String habitId) async {
    final habit = await _databaseService.getHabit(habitId);
    if (habit == null) return {};

    final completions = await _databaseService.getCompletionsByHabit(habitId);
    final completedCompletions =
        completions.where((c) => c.isCompleted).toList();

    final currentStreak = await getCurrentStreak(habitId);
    final longestStreak = await getLongestStreak(habitId);

    // Calculate completion rate over different periods
    final now = DateTime.now();
    final last7Days = now.subtract(const Duration(days: 7));
    final last30Days = now.subtract(const Duration(days: 30));

    final completionsLast7Days =
        completedCompletions
            .where((c) => DateTime.parse(c.date as String).isAfter(last7Days))
            .length;

    final completionsLast30Days =
        completedCompletions
            .where((c) => DateTime.parse(c.date as String).isAfter(last30Days))
            .length;

    // Calculate best day of week
    final dayOfWeekCompletions = <int, int>{};
    for (final completion in completedCompletions) {
      final date = DateTime.parse(completion.date as String);
      final dayOfWeek = date.weekday;
      dayOfWeekCompletions[dayOfWeek] =
          (dayOfWeekCompletions[dayOfWeek] ?? 0) + 1;
    }

    final bestDayOfWeek =
        dayOfWeekCompletions.entries.isNotEmpty
            ? dayOfWeekCompletions.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
            : null;

    // Calculate monthly trend
    final monthlyTrend = <String, int>{};
    for (final completion in completedCompletions) {
      final date = DateTime.parse(completion.date as String);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlyTrend[monthKey] = (monthlyTrend[monthKey] ?? 0) + 1;
    }

    return {
      'habit': habit,
      'totalCompletions': completedCompletions.length,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'completionRate':
          completions.isNotEmpty
              ? completedCompletions.length / completions.length
              : 0.0,
      'completionsLast7Days': completionsLast7Days,
      'completionsLast30Days': completionsLast30Days,
      'weeklyCompletionRate': completionsLast7Days / 7,
      'monthlyCompletionRate': completionsLast30Days / 30,
      'bestDayOfWeek': bestDayOfWeek,
      'dayOfWeekCompletions': dayOfWeekCompletions,
      'monthlyTrend': monthlyTrend,
      'averageCompletionsPerMonth':
          monthlyTrend.values.isNotEmpty
              ? monthlyTrend.values.reduce((a, b) => a + b) /
                  monthlyTrend.length
              : 0.0,
    };
  }

  // Productivity Score
  Future<double> getProductivityScore() async {
    final overallStats = await getOverallStats();
    final streakAnalytics = await getStreakAnalytics();
    final weeklyProgress = await getWeeklyProgress();

    // Factors for productivity score (0-100)
    final completionRate =
        overallStats['todayCompletionRate'] * 30; // 30 points
    final streakScore =
        (streakAnalytics['totalActiveStreaks'] /
            max(overallStats['activeHabits'], 1)) *
        25; // 25 points
    final consistencyScore =
        weeklyProgress['weeklyCompletionRate'] * 25; // 25 points
    final longestStreakScore =
        min(streakAnalytics['longestOverallStreak'] / 30, 1) * 20; // 20 points

    return min(
      completionRate + streakScore + consistencyScore + longestStreakScore,
      100,
    );
  }

  // Habit Insights and Recommendations
  Future<List<Map<String, dynamic>>> getHabitInsights() async {
    final insights = <Map<String, dynamic>>[];
    final habits = await _databaseService.getHabits();
    final overallStats = await getOverallStats();

    for (final habit in habits) {
      if (!habit.isActive) continue;

      final performance = await getHabitPerformance(habit.id);
      final completionRate = performance['completionRate'] ?? 0.0;
      final currentStreak = performance['currentStreak'] ?? 0;

      // Generate insights based on performance
      if (completionRate < 0.3) {
        insights.add({
          'type': 'low_completion',
          'habitId': habit.id,
          'habitName': habit.name,
          'message':
              'Your completion rate for "${habit.name}" is ${(completionRate * 100).toStringAsFixed(1)}%. Consider adjusting the habit or reminder time.',
          'severity': 'high',
          'suggestion':
              'Try breaking this habit into smaller, more manageable steps.',
        });
      } else if (completionRate > 0.8) {
        insights.add({
          'type': 'high_performance',
          'habitId': habit.id,
          'habitName': habit.name,
          'message':
              'Great job! "${habit.name}" has a ${(completionRate * 100).toStringAsFixed(1)}% completion rate.',
          'severity': 'positive',
          'suggestion':
              'Consider adding a complementary habit to build on this success.',
        });
      }

      if (currentStreak >= 21) {
        insights.add({
          'type': 'streak_milestone',
          'habitId': habit.id,
          'habitName': habit.name,
          'message':
              'Congratulations! You have a ${currentStreak}-day streak for "${habit.name}".',
          'severity': 'positive',
          'suggestion': 'You\'re forming a strong habit! Keep up the momentum.',
        });
      }

      // Check for best day of week
      final bestDay = performance['bestDayOfWeek'];
      if (bestDay != null) {
        final dayName = _getDayName(bestDay);
        insights.add({
          'type': 'best_day',
          'habitId': habit.id,
          'habitName': habit.name,
          'message': 'You complete "${habit.name}" most often on ${dayName}s.',
          'severity': 'info',
          'suggestion':
              'Consider scheduling important tasks on your most productive days.',
        });
      }
    }

    // Overall insights
    if (overallStats['todayCompletionRate'] < 0.5) {
      insights.add({
        'type': 'daily_performance',
        'message':
            'You\'ve completed ${(overallStats['todayCompletionRate'] * 100).toStringAsFixed(1)}% of your habits today.',
        'severity': 'medium',
        'suggestion':
            'Try to complete at least one more habit before the day ends.',
      });
    }

    return insights;
  }

  // Time-based Analytics
  Future<Map<String, dynamic>> getTimeBasedAnalytics() async {
    final completions = await _databaseService.getCompletions();
    final completedCompletions =
        completions.where((c) => c.isCompleted).toList();

    final hourlyDistribution = <int, int>{};
    final dayOfWeekDistribution = <int, int>{};
    final monthlyDistribution = <int, int>{};

    for (final completion in completedCompletions) {
      final date = DateTime.parse(completion.date as String);

      // Hour distribution
      final hour = date.hour;
      hourlyDistribution[hour] = (hourlyDistribution[hour] ?? 0) + 1;

      // Day of week distribution
      final dayOfWeek = date.weekday;
      dayOfWeekDistribution[dayOfWeek] =
          (dayOfWeekDistribution[dayOfWeek] ?? 0) + 1;

      // Monthly distribution
      final month = date.month;
      monthlyDistribution[month] = (monthlyDistribution[month] ?? 0) + 1;
    }

    return {
      'hourlyDistribution': hourlyDistribution,
      'dayOfWeekDistribution': dayOfWeekDistribution,
      'monthlyDistribution': monthlyDistribution,
      'mostProductiveHour':
          hourlyDistribution.entries.isNotEmpty
              ? hourlyDistribution.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key
              : null,
      'mostProductiveDayOfWeek':
          dayOfWeekDistribution.entries.isNotEmpty
              ? dayOfWeekDistribution.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key
              : null,
      'mostProductiveMonth':
          monthlyDistribution.entries.isNotEmpty
              ? monthlyDistribution.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key
              : null,
    };
  }

  // Export Analytics Data
  Future<Map<String, dynamic>> exportAnalyticsData() async {
    final overallStats = await getOverallStats();
    final streakAnalytics = await getStreakAnalytics();
    final weeklyProgress = await getWeeklyProgress();
    final monthlyProgress = await getMonthlyProgress();
    final categoryAnalytics = await getCategoryAnalytics();
    final timeBasedAnalytics = await getTimeBasedAnalytics();
    final productivityScore = await getProductivityScore();
    final insights = await getHabitInsights();

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'overallStats': overallStats,
      'streakAnalytics': streakAnalytics,
      'weeklyProgress': weeklyProgress,
      'monthlyProgress': monthlyProgress,
      'categoryAnalytics': categoryAnalytics,
      'timeBasedAnalytics': timeBasedAnalytics,
      'productivityScore': productivityScore,
      'insights': insights,
    };
  }

  // Helper method to get day name
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

  // Helper method to get month name
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

  // Predict habit completion likelihood
  Future<double> predictCompletionLikelihood(String habitId) async {
    final performance = await getHabitPerformance(habitId);
    final completionRate = performance['completionRate'] ?? 0.0;
    final currentStreak = performance['currentStreak'] ?? 0;
    final weeklyRate = performance['weeklyCompletionRate'] ?? 0.0;

    // Simple prediction based on historical data
    final streakFactor = currentStreak > 0 ? 0.2 : 0.0;
    final rateFactor = completionRate * 0.6;
    final recentFactor = weeklyRate * 0.2;

    return min(streakFactor + rateFactor + recentFactor, 1.0);
  }

  // Get habit difficulty analysis
  Future<Map<String, dynamic>> getHabitDifficultyAnalysis() async {
    final habits = await _databaseService.getHabits();
    final difficultyAnalysis = <String, dynamic>{};

    for (final habit in habits) {
      if (!habit.isActive) continue;

      final performance = await getHabitPerformance(habit.id);
      final completionRate = performance['completionRate'] ?? 0.0;
      final currentStreak = performance['currentStreak'] ?? 0;

      String difficulty;
      if (completionRate > 0.8) {
        difficulty = 'Easy';
      } else if (completionRate > 0.6) {
        difficulty = 'Moderate';
      } else if (completionRate > 0.4) {
        difficulty = 'Hard';
      } else {
        difficulty = 'Very Hard';
      }

      difficultyAnalysis[habit.id] = {
        'habitName': habit.name,
        'difficulty': difficulty,
        'completionRate': completionRate,
        'currentStreak': currentStreak,
        'category': habit.category,
      };
    }

    return difficultyAnalysis;
  }
}
