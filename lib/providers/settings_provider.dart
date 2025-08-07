import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  HabitProvider? _habitProvider;

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
    _initializeNotifications();
  }

  void setHabitProvider(HabitProvider habitProvider) {
    _habitProvider = habitProvider;
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
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
      // Validate settings before saving
      if (!_validateSettings(newSettings)) {
        throw Exception('Invalid settings configuration');
      }

      await _databaseService.updateUserSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update settings: $e');
      rethrow; // Re-throw to let UI handle the error
    }
  }

  bool _validateSettings(UserSettings settings) {
    // Validate streak goal
    if (settings.streakGoal <= 0 || settings.streakGoal > 365) {
      return false;
    }

    // Validate language code
    if (!availableLanguages.contains(settings.language)) {
      return false;
    }

    // Validate reminder time
    if (settings.reminderTime.hour < 0 || settings.reminderTime.hour > 23) {
      return false;
    }

    return true;
  }

  Map<String, dynamic> getSettingsAnalytics() {
    return {
      'theme': _settings.isDarkMode ? 'dark' : 'light',
      'notificationsEnabled': _settings.notificationsEnabled,
      'reminderHour': _settings.reminderTime.hour,
      'language': _settings.language,
      'streakGoal': _settings.streakGoal,
      'autoBackup': _settings.autoBackup,
      'lastUpdated': _settings.updatedAt.toIso8601String(),
    };
  }

  Future<void> toggleDarkMode() async {
    final newSettings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    await updateSettings(newSettings);
  }

  Future<void> toggleNotifications() async {
    final newEnabled = !_settings.notificationsEnabled;
    final newSettings = _settings.copyWith(notificationsEnabled: newEnabled);

    if (newEnabled) {
      // Re-enable notifications
      await _notificationService.scheduleHabitReminder(
        _settings.reminderTime,
        'Habit Reminder',
        'Time to complete your daily habits!',
      );

      // Reschedule all habit-specific reminders if we have habit provider
      if (_habitProvider != null) {
        await _notificationService.scheduleMultipleHabitReminders(
          _habitProvider!.habits.where((h) => h.hasReminder).toList(),
        );
      }
    } else {
      // Disable all notifications
      await _notificationService.cancelAllNotifications();
    }

    await updateSettings(newSettings);
  }

  Future<void> updateReminderTime(TimeOfDay newTime) async {
    final newSettings = _settings.copyWith(reminderTime: newTime);

    if (_settings.notificationsEnabled) {
      // Cancel existing notifications
      await _notificationService.cancelAllNotifications();

      // Schedule new general reminder
      await _notificationService.scheduleHabitReminder(
        newTime,
        'Habit Reminder',
        'Time to complete your daily habits!',
      );

      // Reschedule all habit reminders with new time if they don't have custom times
      if (_habitProvider != null) {
        final habitsWithReminders =
            _habitProvider!.habits.where((h) => h.hasReminder).toList();

        await _notificationService.rescheduleAllHabitReminders(
          habitsWithReminders,
          newTime,
        );
      }
    }

    await updateSettings(newSettings);
  }

  Future<bool> exportSettingsToFile() async {
    try {
      final settingsData = getExportableSettings();
      // Here you would implement file export logic
      // For now, just return true to indicate success
      debugPrint('Settings exported: $settingsData');
      return true;
    } catch (e) {
      debugPrint('Failed to export settings: $e');
      return false;
    }
  }

  Future<bool> importSettingsFromFile(Map<String, dynamic> settingsData) async {
    try {
      final importedSettings = UserSettings.fromJson(settingsData);
      await updateSettings(importedSettings);
      return true;
    } catch (e) {
      debugPrint('Failed to import settings: $e');
      return false;
    }
  }

  Future<void> syncWithSystemSettings() async {
    try {
      // Check if notifications are actually enabled at system level
      final systemNotificationsEnabled =
          await _notificationService.areNotificationsEnabled();

      if (!systemNotificationsEnabled && _settings.notificationsEnabled) {
        // System disabled notifications, update our settings
        final newSettings = _settings.copyWith(notificationsEnabled: false);
        await updateSettings(newSettings);
      }
    } catch (e) {
      debugPrint('Error syncing with system settings: $e');
    }
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
