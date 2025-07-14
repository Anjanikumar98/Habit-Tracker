import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String title;
  final String category;
  final Color color;
  final String frequency;
  final int weeklyGoal;
  final DateTime createdAt;
  final bool isActive;

  // Computed properties
  int currentStreak;
  int bestStreak;
  int completedThisWeek;
  bool isCompletedToday;
  double weeklyProgress;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.color,
    required this.frequency,
    required this.weeklyGoal,
    required this.createdAt,
    this.isActive = true,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.completedThisWeek = 0,
    this.isCompletedToday = false,
    this.weeklyProgress = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'color': color.value,
      'frequency': frequency,
      'weeklyGoal': weeklyGoal,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      color: Color(map['color']),
      frequency: map['frequency'],
      weeklyGoal: map['weeklyGoal'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] == 1,
      currentStreak: map['currentStreak'] ?? 0,
      bestStreak: map['bestStreak'] ?? 0,
    );
  }
}
