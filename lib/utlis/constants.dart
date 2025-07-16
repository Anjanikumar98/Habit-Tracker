import 'package:flutter/material.dart';

class Constants {
  static const String appName = 'Habit Tracker';
  static const String appVersion = '1.0.0';

  static const List<String> categories = [
    'Health & Fitness',
    'Personal Development',
    'Productivity',
    'Social',
    'Hobbies',
    'Finance',
    'Education',
    'Mindfulness',
    'Other',
  ];

  static const List<String> frequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Custom',
  ];

  static const List<String> habitColors = [
    '#6f1bff',
    '#ff6b6b',
    '#4ecdc4',
    '#45b7d1',
    '#96ceb4',
    '#feca57',
    '#ff9ff3',
    '#54a0ff',
    '#5f27cd',
    '#00d2d3',
  ];

  static final List<Color> habitColorList =
      habitColors
          .map(
            (hex) => Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000),
          )
          .toList();

  static const int maxHabitNameLength = 50;
  static const int maxDescriptionLength = 200;
  static const int maxTagsCount = 5;
  static const int streakGoal = 21;
}
