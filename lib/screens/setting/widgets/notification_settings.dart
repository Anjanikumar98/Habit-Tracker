import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:provider/provider.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Enable Notifications', style: TextStyle(fontSize: 16)),
        Switch(
          value: _notificationsEnabled,
          onChanged: (value) async {
            setState(() {
              _notificationsEnabled = value;
            });

            final habitProvider = Provider.of<HabitProvider>(
              context,
              listen: false,
            );
            final habits = habitProvider.habits;

            if (_notificationsEnabled) {
              for (final habit in habits) {
                if (habit.hasReminder && habit.reminderTime != null) {
                  await NotificationService().scheduleSpecificHabitReminder(
                    habit,
                    habit.reminderTime!, // Make sure it's not null
                  );
                }
              }
            } else {
              await NotificationService().cancelAllNotifications();
            }
          },
        ),
      ],
    );
  }
}
