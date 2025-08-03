import 'dart:async';

import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../services/database_service.dart';

class HabitProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
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

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _dbSubscription?.cancel();
    super.dispose();
  }

  HabitProvider() {
    loadHabits();
  }

  // Check if habit is completed today
  bool isHabitCompletedToday(Habit habit) {
    final today = DateTime.now();
    return habit.completedDates.any(
      (d) =>
          d.year == today.year && d.month == today.month && d.day == today.day,
    );
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

  Future<void> addHabit(Habit habit) async {
    try {
      final newHabit = await _databaseService.insertHabit(habit);
      _habits.add(newHabit);
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
        _habits[index] = habit;
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
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete habit: $e';
      notifyListeners();
    }
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    try {
      final existingCompletion = _completions.firstWhere(
        (c) => c.habitId == habitId && isSameDay(c.date, date),
        orElse:
            () => HabitCompletion(
              id: '',
              habitId: habitId,
              date: date,
              isCompleted: false,
            ),
      );

      if (existingCompletion.id.isEmpty) {
        // Create new completion
        final newCompletion = HabitCompletion(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          habitId: habitId,
          date: date,
          isCompleted: true,
        );
        await _databaseService.insertCompletion(newCompletion);
        _completions.add(newCompletion);
      } else {
        // Update existing completion
        final updatedCompletion = existingCompletion.copyWith(
          isCompleted: !existingCompletion.isCompleted,
        );
        await _databaseService.updateCompletion(updatedCompletion);
        final index = _completions.indexWhere(
          (c) => c.id == existingCompletion.id,
        );
        if (index != -1) {
          _completions[index] = updatedCompletion;
        }
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update completion: $e';
      notifyListeners();
    }
  }

  bool isHabitCompletedOnDate(String habitId, DateTime date) {
    return _completions.any(
      (c) => c.habitId == habitId && isSameDay(c.date, date) && c.isCompleted,
    );
  }

  // Add these methods to your HabitProvider class
  int getCompletedTodayCount() {
    final today = DateTime.now();
    return habits.where((habit) => isHabitCompletedToday(habit)).length;
  }

  int getLongestStreak() {
    if (habits.isEmpty) return 0;
    return habits
        .map((habit) => getHabitStreak(habit.id))
        .reduce((max, current) => current > max ? current : max);
  }

  double getOverallSuccessRate() {
    if (habits.isEmpty) return 0.0;
    final totalRate = habits
        .map((habit) => getHabitCompletionRate(habit.id))
        .reduce((sum, rate) => sum + rate);
    return totalRate / habits.length;
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

  List<Habit> getHabitsByCategory(String category) {
    return _habits.where((h) => h.category == category).toList();
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
