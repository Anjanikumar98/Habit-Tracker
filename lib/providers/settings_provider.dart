import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  UserSettings _settings = UserSettings(
    id: '1',
    isDarkMode: false,
    notificationsEnabled: true,
    reminderTime: TimeOfDay(hour: 9, minute: 0),
    weekStartsOnMonday: true,
    streakGoal: 21,
    language: 'en',
    showCompletionAnimation: true,
    autoBackup: false,
    soundEnabled: true,
    vibrationEnabled: true,
  );

  UserSettings get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  TimeOfDay get reminderTime => _settings.reminderTime;
  bool get weekStartsOnMonday => _settings.weekStartsOnMonday;
  int get streakGoal => _settings.streakGoal;
  String get language => _settings.language;
  bool get showCompletionAnimation => _settings.showCompletionAnimation;
  bool get autoBackup => _settings.autoBackup;
  bool get soundEnabled => _settings.soundEnabled;
  bool get vibrationEnabled => _settings.vibrationEnabled;

  SettingsProvider() {
    loadSettings();
  }

  // Method to get formatted reminder time
  String getFormattedReminderTime(BuildContext context) {
    return _settings.reminderTime.format(context);
  }

  // Method to validate streak goal
  bool isValidStreakGoal(int goal) {
    return goal > 0 && goal <= 365;
  }

  // Method to get settings as exportable JSON
  Map<String, dynamic> getExportableSettings() {
    return {
      ..._settings.toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
    };
  }

  Future<void> loadSettings() async {
    try {
      final loadedSettings = await _databaseService.getUserSettings();
      if (loadedSettings != null) {
        _settings = loadedSettings;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    try {
      await _databaseService.updateUserSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update settings: $e');
    }
  }

  Future<void> toggleDarkMode() async {
    final newSettings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await updateSettings(newSettings);
  }

  Future<void> toggleNotifications() async {
    final newEnabled = !_settings.notificationsEnabled;
    final newSettings = _settings.copyWith(notificationsEnabled: newEnabled);

    if (newEnabled) {
      await _notificationService.scheduleHabitReminder(
        _settings.reminderTime,
        'Habit Reminder',
        'Time to complete your daily habits!',
      );
    } else {
      await _notificationService.cancelAllNotifications();
    }

    await updateSettings(newSettings);
  }

  Future<void> updateReminderTime(TimeOfDay newTime) async {
    final newSettings = _settings.copyWith(reminderTime: newTime);

    if (_settings.notificationsEnabled) {
      await _notificationService.scheduleHabitReminder(
        newTime,
        'Habit Reminder',
        'Time to complete your daily habits!',
      );
    }

    await updateSettings(newSettings);
  }

  Future<void> toggleWeekStartsOnMonday() async {
    final newSettings = _settings.copyWith(
      weekStartsOnMonday: !_settings.weekStartsOnMonday,
    );
    await updateSettings(newSettings);
  }

  Future<void> updateStreakGoal(int newGoal) async {
    if (newGoal > 0 && newGoal <= 365) {
      final newSettings = _settings.copyWith(streakGoal: newGoal);
      await updateSettings(newSettings);
    }
  }

  Future<void> updateLanguage(String newLanguage) async {
    final newSettings = _settings.copyWith(language: newLanguage);
    await updateSettings(newSettings);
  }

  Future<void> toggleCompletionAnimation() async {
    final newSettings = _settings.copyWith(
      showCompletionAnimation: !_settings.showCompletionAnimation,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleAutoBackup() async {
    final newSettings = _settings.copyWith(autoBackup: !_settings.autoBackup);
    await updateSettings(newSettings);
  }

  Future<void> toggleSound() async {
    final newSettings = _settings.copyWith(
      soundEnabled: !_settings.soundEnabled,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleVibration() async {
    final newSettings = _settings.copyWith(
      vibrationEnabled: !_settings.vibrationEnabled,
    );
    await updateSettings(newSettings);
  }

  Future<void> resetSettings() async {
    final defaultSettings = UserSettings(
      id: '1',
      isDarkMode: false,
      notificationsEnabled: true,
      reminderTime: TimeOfDay(hour: 9, minute: 0),
      weekStartsOnMonday: true,
      streakGoal: 21,
      language: 'en',
      showCompletionAnimation: true,
      autoBackup: false,
      soundEnabled: true,
      vibrationEnabled: true,
    );

    await updateSettings(defaultSettings);
  }

  Future<void> exportSettings() async {
    // Implementation for exporting settings
    // This could export to JSON file or cloud storage
    try {
      // Example: Save to local storage or cloud
      debugPrint('Exporting settings: ${_settings.toJson()}');
    } catch (e) {
      debugPrint('Failed to export settings: $e');
    }
  }

  Future<void> importSettings(Map<String, dynamic> settingsData) async {
    try {
      final importedSettings = UserSettings.fromJson(settingsData);
      await updateSettings(importedSettings);
    } catch (e) {
      debugPrint('Failed to import settings: $e');
    }
  }

  List<String> get availableLanguages => [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'zh',
    'ja',
    'ko',
  ];

  String getLanguageName(String code) {
    final languageNames = {
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
    return languageNames[code] ?? 'Unknown';
  }
}
