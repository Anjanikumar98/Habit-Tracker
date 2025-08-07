import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestExactAlarmsPermission();
      await androidImplementation.requestNotificationsPermission();
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload != null) {
      debugPrint('Notification payload: $payload');
      // Handle notification tap
      // You can navigate to specific screens based on payload
    }
  }

  Future<void> scheduleHabitReminder(
    TimeOfDay time,
    String title,
    String body, {
    String? payload,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time is in the past, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0, // notification ID
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminder_channel',
          'Habit Reminders',
          channelDescription: 'Notifications for habit reminders',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // Keep this if you want daily repetition
      payload: payload,
    );
  }

  Future<void> scheduleSpecificHabitReminder(
    Habit habit,
    TimeOfDay time,
  ) async {
    if (!habit.hasReminder) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time is in the past, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      habit.id.hashCode, // Use habit ID as notification ID
      'Habit Reminder',
      habit.reminderText ?? 'Time to complete: ${habit.name}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'specific_habit_reminder_channel',
          'Specific Habit Reminders',
          channelDescription: 'Notifications for specific habit reminders',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // 🔁 for daily repetition
      payload: habit.id,
    );
  }

  Future<void> showInstantNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel',
          'Instant Notifications',
          channelDescription: 'Instant notifications for habit completion',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> showHabitCompletionNotification(Habit habit) async {
    await showInstantNotification(
      'Habit Completed! 🎉',
      'Great job completing "${habit.name}"! Keep up the streak!',
      payload: habit.id,
    );
  }

  Future<void> showStreakMilestoneNotification(Habit habit, int streak) async {
    String message;
    String emoji;

    if (streak >= 100) {
      message = 'Incredible! $streak days in a row!';
      emoji = '🏆';
    } else if (streak >= 50) {
      message = 'Amazing! $streak days in a row!';
      emoji = '🔥';
    } else if (streak >= 30) {
      message = 'Fantastic! $streak days in a row!';
      emoji = '⭐';
    } else if (streak >= 21) {
      message = 'Great! $streak days in a row!';
      emoji = '💪';
    } else if (streak >= 7) {
      message = 'One week streak! $streak days in a row!';
      emoji = '🎯';
    } else {
      message = '$streak days in a row!';
      emoji = '✨';
    }

    await showInstantNotification(
      'Streak Milestone! $emoji',
      '"${habit.name}" - $message',
      payload: habit.id,
    );
  }

  Future<void> showMotivationalNotification(String message) async {
    await showInstantNotification('Stay Motivated! 💪', message);
  }

  Future<void> scheduleMultipleHabitReminders(List<Habit> habits) async {
    for (final habit in habits) {
      if (habit.hasReminder && habit.reminderTime != null) {
        await scheduleSpecificHabitReminder(habit, habit.reminderTime!);
      }
    }
  }

  Future<void> cancelHabitReminder(String habitId) async {
    await _flutterLocalNotificationsPlugin.cancel(habitId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelSpecificNotification(int notificationId) async {
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> rescheduleAllHabitReminders(
    List<Habit> habits,
    TimeOfDay newTime,
  ) async {
    // Cancel all existing notifications
    await cancelAllNotifications();

    // Schedule general reminder
    await scheduleHabitReminder(
      newTime,
      'Habit Reminder',
      'Time to complete your daily habits!',
    );

    // Schedule specific habit reminders
    for (final habit in habits) {
      if (habit.hasReminder) {
        await scheduleSpecificHabitReminder(habit, newTime);
      }
    }
  }

  Future<void> scheduleWeeklyProgressNotification(TimeOfDay time) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Schedule for next Sunday (or today if it's Sunday and time hasn't passed)
    final daysUntilSunday = (DateTime.sunday - now.weekday) % 7;
    if (daysUntilSunday == 0 && scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    } else {
      scheduledDate = scheduledDate.add(Duration(days: daysUntilSunday));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      999, // Use a specific ID for weekly notifications
      'Weekly Progress Review 📊',
      'Check your weekly habit progress and plan for the next week!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_progress_channel',
          'Weekly Progress',
          channelDescription: 'Weekly progress review notifications',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // 🔁 Weekly repetition
      payload: 'weekly_progress',
    );
  }

  Future<bool> areNotificationsEnabled() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iosImplementation != null) {
      final settings = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings ?? false;
    }

    return false;
  }

  // Add notification channels for better Android support
  Future<void> _createNotificationChannels() async {
    const habitReminders = AndroidNotificationChannel(
      'habit_reminders',
      'Habit Reminders',
      description: 'Daily habit reminder notifications',
      importance: Importance.high,
    );

    const achievements = AndroidNotificationChannel(
      'achievements',
      'Achievements',
      description: 'Streak milestones and achievements',
      importance: Importance.defaultImportance,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(habitReminders);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(achievements);
  }

  void dispose() {
    // Clean up resources if needed
  }
}
