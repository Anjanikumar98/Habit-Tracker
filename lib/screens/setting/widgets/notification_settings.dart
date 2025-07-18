import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enable/Disable Notifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enable Notifications',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: settingsProvider.notificationsEnabled,
                      onChanged: (value) async {
                        await settingsProvider.toggleNotifications();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? 'Notifications enabled'
                                    : 'Notifications disabled',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),

                // Notification Settings (only show if enabled)
                if (settingsProvider.notificationsEnabled) ...[
                  const Divider(),

                  // Reminder Time
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule),
                    title: const Text('Reminder Time'),
                    subtitle: Text(
                      settingsProvider.reminderTime.format(context),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _selectReminderTime(context, settingsProvider),
                  ),

                  // Sound Settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sound'),
                      Switch(
                        value: settingsProvider.soundEnabled,
                        onChanged: (value) => settingsProvider.toggleSound(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Vibration Settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Vibration'),
                      Switch(
                        value: settingsProvider.vibrationEnabled,
                        onChanged:
                            (value) => settingsProvider.toggleVibration(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectReminderTime(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: settingsProvider.reminderTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && picked != settingsProvider.reminderTime) {
      await settingsProvider.updateReminderTime(picked);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder time updated to ${picked.format(context)}'),
          ),
        );
      }
    }
  }
}
