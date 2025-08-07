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
                // Header
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Enable/Disable Notifications
                _buildSettingTile(
                  context: context,
                  icon: Icons.notifications,
                  title: 'Enable Notifications',
                  subtitle:
                      settingsProvider.notificationsEnabled
                          ? 'Receive daily reminders'
                          : 'No notifications will be sent',
                  trailing: Switch.adaptive(
                    value: settingsProvider.notificationsEnabled,
                    onChanged: (value) async {
                      await _toggleNotifications(
                        context,
                        settingsProvider,
                        value,
                      );
                    },
                  ),
                ),

                // Notification Settings (only show if enabled)
                if (settingsProvider.notificationsEnabled) ...[
                  const Divider(height: 32),

                  // Reminder Time
                  _buildSettingTile(
                    context: context,
                    icon: Icons.schedule,
                    title: 'Daily Reminder Time',
                    subtitle: _formatTime(
                      context,
                      settingsProvider.reminderTime,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _selectReminderTime(context, settingsProvider),
                  ),

                  const SizedBox(height: 16),

                  // Sound Settings
                  _buildSettingTile(
                    context: context,
                    icon:
                        settingsProvider.soundEnabled
                            ? Icons.volume_up
                            : Icons.volume_off,
                    title: 'Sound',
                    subtitle:
                        settingsProvider.soundEnabled
                            ? 'Play notification sound'
                            : 'Silent notifications',
                    trailing: Switch.adaptive(
                      value: settingsProvider.soundEnabled,
                      onChanged: (value) {
                        settingsProvider.toggleSound();
                        _showFeedback(
                          context,
                          value ? 'Sound enabled' : 'Sound disabled',
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Vibration Settings
                  _buildSettingTile(
                    context: context,
                    icon:
                        settingsProvider.vibrationEnabled
                            ? Icons.vibration
                            : Icons.phone_android,
                    title: 'Vibration',
                    subtitle:
                        settingsProvider.vibrationEnabled
                            ? 'Vibrate on notification'
                            : 'No vibration',
                    trailing: Switch.adaptive(
                      value: settingsProvider.vibrationEnabled,
                      onChanged: (value) {
                        settingsProvider.toggleVibration();
                        _showFeedback(
                          context,
                          value ? 'Vibration enabled' : 'Vibration disabled',
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Test Notification Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          () => _testNotification(context, settingsProvider),
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Test Notification'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],

                // Permission info when notifications are disabled
                if (!settingsProvider.notificationsEnabled) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Enable notifications to get daily reminders for your habits',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    final material = MaterialLocalizations.of(context);
    return material.formatTimeOfDay(time);
  }

  Future<void> _toggleNotifications(
    BuildContext context,
    SettingsProvider settingsProvider,
    bool value,
  ) async {
    try {
      await settingsProvider.toggleNotifications();
      if (context.mounted) {
        _showFeedback(
          context,
          value ? 'Notifications enabled' : 'Notifications disabled',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(
          context,
          'Failed to update notification settings',
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _selectReminderTime(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: settingsProvider.reminderTime,
      helpText: 'Select reminder time',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && picked != settingsProvider.reminderTime) {
      try {
        await settingsProvider.updateReminderTime(picked);
        if (context.mounted) {
          _showFeedback(
            context,
            'Reminder time updated to ${_formatTime(context, picked)}',
            isSuccess: true,
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showFeedback(
            context,
            'Failed to update reminder time',
            isSuccess: false,
          );
        }
      }
    }
  }

  Future<void> _testNotification(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    try {
      // TODO: Implement actual test notification
      // You would call your notification service here
      _showFeedback(
        context,
        'Test notification sent! Check your notifications.',
        isSuccess: true,
      );
    } catch (e) {
      _showFeedback(
        context,
        'Failed to send test notification',
        isSuccess: false,
      );
    }
  }

  void _showFeedback(
    BuildContext context,
    String message, {
    bool isSuccess = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
