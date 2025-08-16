import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habit_tracker/services/analytics_service.dart';
import 'package:habit_tracker/services/notification_service.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../services/database_service.dart';


class HabitProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final NotificationService _notificationService = NotificationService();
  // final _uuid = Uuid();

  List<Habit> _habits = [];
  List<HabitCompletion> _completions = [];
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  List<HabitCompletion> get completions => _completions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Timer? _refreshTimer;
  StreamSubscription? _dbSubscription;

  Future<void> initialize() async {
    await loadHabits();
    await loadCompletions();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _dbSubscription?.cancel();
    super.dispose();
  }

  HabitProvider() {
    loadHabits();
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (_) {
      loadHabits();
    });
  }

  // Check if habit is completed today
  bool isHabitCompletedToday(String habitId) {
    final today = DateTime.now();
    return _completions.any((completion) {
      return completion.habitId == habitId &&
          completion.date.year == today.year &&
          completion.date.month == today.month &&
          completion.date.day == today.day &&
          completion.isCompleted;
    });
  }

  double getCompletionRate(Habit habit) {
    if (habit.completions.isEmpty) return 0.0;

    final firstDate = habit.completions
        .map((c) => c.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final totalDays = DateTime.now().difference(firstDate).inDays + 1;
    return habit.totalCompletions / totalDays;
  }

  Future<void> loadHabits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _habits = await _databaseService.getHabits();
      _completions = await _databaseService.getCompletions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load habits: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load completions from database
  Future<void> loadCompletions() async {
    try {
      _completions = await _databaseService.getCompletions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading completions: $e');
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      final newHabit = await _databaseService.insertHabit(habit);
      _habits.add(newHabit);

      // Schedule notifications if habit has reminder
      if (newHabit.hasReminder && newHabit.reminderTime != null) {
        await _notificationService.scheduleSpecificHabitReminder(
          newHabit,
          newHabit.reminderTime!,
        );
      }

      _analyticsService.clearCache();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add habit: $e';
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _databaseService.updateHabit(habit);
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        final oldHabit = _habits[index];
        _habits[index] = habit;

        // Update notifications if reminder changed
        if (oldHabit.reminderTime != habit.reminderTime) {
          await _notificationService.cancelHabitReminder(habit.id);
          if (habit.hasReminder && habit.reminderTime != null) {
            await _notificationService.scheduleSpecificHabitReminder(
              habit,
              habit.reminderTime!,
            );
          }
        }
        _analyticsService.clearCache();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update habit: $e';
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      await _databaseService.deleteHabit(habitId);
      _habits.removeWhere((h) => h.id == habitId);
      _completions.removeWhere((c) => c.habitId == habitId);

      // Cancel associated notifications
      await _notificationService.cancelHabitReminder(habitId);

      _analyticsService.clearCache();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete habit: $e';
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      return await _analyticsService.getOverallStatsWithCache();
    } catch (e) {
      print('Error getting analytics: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getStreakAnalytics() async {
    try {
      return await _analyticsService.getStreakAnalytics();
    } catch (e) {
      print('Error getting streak analytics: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getHabitInsights() async {
    try {
      return await _analyticsService.getHabitInsights();
    } catch (e) {
      print('Error getting habit insights: $e');
      return [];
    }
  }

  Future<void> batchUpdateCompletions(List<HabitCompletion> completions) async {
    try {
      await _databaseService.batchUpdateCompletions(completions);
      await loadHabits(); // Refresh data
      _analyticsService.clearCache();
    } catch (e) {
      _error = 'Failed to batch update completions: $e';
      notifyListeners();
    }
  }

  List<Habit> getTodaysActiveHabits() {
    final today = DateTime.now();
    return _habits.where((habit) {
      if (!habit.isActive) return false;
      return habit.shouldShowToday(today);
    }).toList();
  }

  // Get completion statistics
  Map<String, dynamic> getTodayStats() {
    final todaysHabits = getTodaysActiveHabits();
    final completedToday =
        todaysHabits
            .where((h) => isHabitCompletedOnDate(h.id, DateTime.now()))
            .length;

    return {
      'totalHabits': todaysHabits.length,
      'completedHabits': completedToday,
      'completionRate':
          todaysHabits.isNotEmpty ? completedToday / todaysHabits.length : 0.0,
      'remainingHabits': todaysHabits.length - completedToday,
    };
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime dateTime) async {
    try {
      final today = DateTime.now();
      final existingCompletion = await _databaseService
          .getCompletionByHabitAndDate(habitId, today);

      if (existingCompletion != null) {
        // Update existing completion
        final updatedCompletion = existingCompletion.copyWith(
          isCompleted: !existingCompletion.isCompleted,
        );
        await _databaseService.updateCompletion(updatedCompletion);

        // Update local list
        final index = _completions.indexWhere(
          (c) => c.id == existingCompletion.id,
        );
        if (index != -1) {
          _completions[index] = updatedCompletion;
        }
      } else {
        // Create new completion
        final newCompletion = HabitCompletion(
          id: generateCustomId(),
          habitId: habitId,
          date: today,
          isCompleted: true,
        );
        await _databaseService.insertCompletion(newCompletion);
        _completions.add(newCompletion);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling habit completion: $e');
      rethrow;
    }
  }

  String generateCustomId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = Random().nextInt(
      1000000,
    ); // You can increase digits if needed
    return '$timestamp-$randomPart';
  }

  bool isHabitCompletedOnDate(String habitId, DateTime date) {
    return _completions.any(
      (c) => c.habitId == habitId && isSameDay(c.date, date) && c.isCompleted,
    );
  }

  // Add these methods to your HabitProvider class
  int getCompletedTodayCount() {
    final today = DateTime.now();
    return habits
        .where((habit) => isHabitCompletedToday(habit as String))
        .length;
  }

  int getLongestStreak() {
    if (habits.isEmpty) return 0;
    return habits
        .map((habit) => getHabitStreak(habit.id))
        .reduce((max, current) => current > max ? current : max);
  }

  double getOverallSuccessRate() {
    if (_habits.isEmpty) return 0.0;

    final totalExpected = _habits.length * 30; // Last 30 days
    final totalCompleted =
        _completions.where((completion) {
          final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
          return completion.date.isAfter(thirtyDaysAgo) &&
              completion.isCompleted;
        }).length;

    return totalExpected > 0 ? totalCompleted / totalExpected : 0.0;
  }

  int getCurrentStreak() {
    if (habits.isEmpty) return 0;
    return habits
        .map((habit) => getHabitStreak(habit.id))
        .reduce((max, current) => current > max ? current : max);
  }

  int getHabitStreak(String habitId) {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    final completions =
        _completions
            .where((c) => c.habitId == habitId && c.isCompleted)
            .toList();

    if (completions.isEmpty) return 0;

    completions.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final checkDate = currentDate.subtract(Duration(days: i));
      final isCompleted = completions.any((c) => isSameDay(c.date, checkDate));

      if (isCompleted) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  double getHabitCompletionRate(String habitId, {int days = 30}) {
    final completions =
        _completions
            .where((c) => c.habitId == habitId && c.isCompleted)
            .where(
              (c) =>
                  c.date.isAfter(DateTime.now().subtract(Duration(days: days))),
            )
            .length;

    return completions / days;
  }

  // Get completions for specific habit
  List<HabitCompletion> getHabitCompletions(String habitId) {
    return _completions.where((c) => c.habitId == habitId).toList();
  }

  // Get habits by category
  List<Habit> getHabitsByCategory(String category) {
    return _habits.where((habit) => habit.category == category).toList();
  }

  List<Habit> getTodaysHabits() {
    final today = DateTime.now();
    return _habits.where((h) {
      switch (h.frequency) {
        case 'Daily':
          return true;
        case 'Weekly':
          return today.weekday == 1; // Monday
        case 'Monthly':
          return today.day == 1;
        default:
          return true;
      }
    }).toList();
  }

  Map<String, dynamic> getOverallStats() {
    final totalHabits = _habits.length;
    final completedToday =
        getTodaysHabits()
            .where((h) => isHabitCompletedOnDate(h.id, DateTime.now()))
            .length;

    final totalCompletions = _completions.where((c) => c.isCompleted).length;
    final avgStreak =
        _habits.isEmpty
            ? 0
            : _habits.map((h) => getHabitStreak(h.id)).reduce((a, b) => a + b) /
                _habits.length;

    return {
      'totalHabits': totalHabits,
      'completedToday': completedToday,
      'totalCompletions': totalCompletions,
      'averageStreak': avgStreak.round(),
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void completeHabit(String habitId) {
    final habit = _habits.firstWhere(
      (h) => h.id == habitId,
      orElse: () => throw Exception('Habit not found'),
    );

    final now = DateTime.now();

    // Avoid duplicate completion for the same day
    final alreadyCompletedToday = habit.completedDates.any(
      (d) => d.year == now.year && d.month == now.month && d.day == now.day,
    );

    if (!alreadyCompletedToday) {
      final completion = HabitCompletion(
        id: UniqueKey().toString(), // or use UUID if needed
        habitId: habit.id,
        date: now,
        isCompleted: true,
      );

      habit.completions.add(completion);
      notifyListeners();
    }
  }
}

