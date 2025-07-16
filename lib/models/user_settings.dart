import 'package:flutter/material.dart';

class UserSettings {
  final String id;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final TimeOfDay reminderTime;
  final bool weekStartsOnMonday;
  final int streakGoal;
  final String language;
  final bool showCompletionAnimation;
  final bool autoBackup;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettings({
    required this.id,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.reminderTime,
    required this.weekStartsOnMonday,
    required this.streakGoal,
    required this.language,
    required this.showCompletionAnimation,
    required this.autoBackup,
    required this.soundEnabled,
    required this.vibrationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Copy with method for immutability
  UserSettings copyWith({
    String? id,
    bool? isDarkMode,
    bool? notificationsEnabled,
    TimeOfDay? reminderTime,
    bool? weekStartsOnMonday,
    int? streakGoal,
    String? language,
    bool? showCompletionAnimation,
    bool? autoBackup,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      weekStartsOnMonday: weekStartsOnMonday ?? this.weekStartsOnMonday,
      streakGoal: streakGoal ?? this.streakGoal,
      language: language ?? this.language,
      showCompletionAnimation:
          showCompletionAnimation ?? this.showCompletionAnimation,
      autoBackup: autoBackup ?? this.autoBackup,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'reminderTimeHour': reminderTime.hour,
      'reminderTimeMinute': reminderTime.minute,
      'weekStartsOnMonday': weekStartsOnMonday,
      'streakGoal': streakGoal,
      'language': language,
      'showCompletionAnimation': showCompletionAnimation,
      'autoBackup': autoBackup,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as String,
      isDarkMode: json['isDarkMode'] as bool,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      reminderTime: TimeOfDay(
        hour: json['reminderTimeHour'] as int,
        minute: json['reminderTimeMinute'] as int,
      ),
      weekStartsOnMonday: json['weekStartsOnMonday'] as bool,
      streakGoal: json['streakGoal'] as int,
      language: json['language'] as String,
      showCompletionAnimation: json['showCompletionAnimation'] as bool,
      autoBackup: json['autoBackup'] as bool,
      soundEnabled: json['soundEnabled'] as bool,
      vibrationEnabled: json['vibrationEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'is_dark_mode': isDarkMode ? 1 : 0,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'reminder_time_hour': reminderTime.hour,
      'reminder_time_minute': reminderTime.minute,
      'week_starts_on_monday': weekStartsOnMonday ? 1 : 0,
      'streak_goal': streakGoal,
      'language': language,
      'show_completion_animation': showCompletionAnimation ? 1 : 0,
      'auto_backup': autoBackup ? 1 : 0,
      'sound_enabled': soundEnabled ? 1 : 0,
      'vibration_enabled': vibrationEnabled ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from database map
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as String,
      isDarkMode: (map['is_dark_mode'] as int) == 1,
      notificationsEnabled: (map['notifications_enabled'] as int) == 1,
      reminderTime: TimeOfDay(
        hour: map['reminder_time_hour'] as int,
        minute: map['reminder_time_minute'] as int,
      ),
      weekStartsOnMonday: (map['week_starts_on_monday'] as int) == 1,
      streakGoal: map['streak_goal'] as int,
      language: map['language'] as String,
      showCompletionAnimation: (map['show_completion_animation'] as int) == 1,
      autoBackup: (map['auto_backup'] as int) == 1,
      soundEnabled: (map['sound_enabled'] as int) == 1,
      vibrationEnabled: (map['vibration_enabled'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Utility methods
  String get formattedReminderTime {
    final hour = reminderTime.hour;
    final minute = reminderTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String get themeDisplayName {
    return isDarkMode ? 'Dark' : 'Light';
  }

  String get languageDisplayName {
    const languageNames = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'ru': 'Русский',
      'zh': '中文',
      'ja': '日本語',
      'ko': '한국어',
    };
    return languageNames[language] ?? 'Unknown';
  }

  bool get hasValidStreakGoal {
    return streakGoal > 0 && streakGoal <= 365;
  }

  List<int> get weekdays {
    if (weekStartsOnMonday) {
      return [1, 2, 3, 4, 5, 6, 7]; // Monday to Sunday
    } else {
      return [7, 1, 2, 3, 4, 5, 6]; // Sunday to Saturday
    }
  }

  @override
  String toString() {
    return 'UserSettings(id: $id, isDarkMode: $isDarkMode, notificationsEnabled: $notificationsEnabled, reminderTime: $reminderTime, weekStartsOnMonday: $weekStartsOnMonday, streakGoal: $streakGoal, language: $language, showCompletionAnimation: $showCompletionAnimation, autoBackup: $autoBackup, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.id == id &&
        other.isDarkMode == isDarkMode &&
        other.notificationsEnabled == notificationsEnabled &&
        other.reminderTime == reminderTime &&
        other.weekStartsOnMonday == weekStartsOnMonday &&
        other.streakGoal == streakGoal &&
        other.language == language &&
        other.showCompletionAnimation == showCompletionAnimation &&
        other.autoBackup == autoBackup &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        isDarkMode.hashCode ^
        notificationsEnabled.hashCode ^
        reminderTime.hashCode ^
        weekStartsOnMonday.hashCode ^
        streakGoal.hashCode ^
        language.hashCode ^
        showCompletionAnimation.hashCode ^
        autoBackup.hashCode ^
        soundEnabled.hashCode ^
        vibrationEnabled.hashCode;
  }
}
