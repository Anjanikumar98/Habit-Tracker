import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/settings_provider.dart';
import 'package:habit_tracker/screens/onboarding/onboarding_screen.dart';
import 'package:habit_tracker/screens/setting/widgets/backup_restore.dart';
import 'package:habit_tracker/screens/setting/widgets/notification_settings.dart';
import 'package:habit_tracker/screens/setting/widgets/theme_selector.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Settings', showBackButton: false),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader(context, 'Appearance'),
            const ThemeSelector(),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Notifications'),
            const NotificationSettings(),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Habits'),
            _buildHabitsSection(context),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Language'),
            _buildLanguageSection(context),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Data'),
            const BackupRestore(),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'About'),
            _buildAboutSection(context),
            const SizedBox(height: 24),

            _buildResetSection(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildHabitsSection(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Week Starts On'),
                  subtitle: Text(
                    settingsProvider.weekStartsOnMonday ? 'Monday' : 'Sunday',
                  ),
                  trailing: Switch(
                    value: settingsProvider.weekStartsOnMonday,
                    onChanged:
                        (value) => settingsProvider.toggleWeekStartsOnMonday(),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.local_fire_department),
                  title: const Text('Streak Goal'),
                  subtitle: Text('${settingsProvider.streakGoal} days'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showStreakGoalDialog(context, settingsProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_backup_restore),
                  title: const Text('Auto Backup'),
                  subtitle: const Text('Automatically backup data'),
                  trailing: Switch(
                    value: settingsProvider.autoBackup,
                    onChanged: (value) => settingsProvider.toggleAutoBackup(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(
              settingsProvider.getLanguageName(settingsProvider.language),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context, settingsProvider),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            onTap: () => _showVersionDialog(context),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showHelpDialog(context),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPrivacyDialog(context),
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Show Onboarding'),
            subtitle: const Text('Replay the app introduction'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OnboardingScreen(),
                ),
              );
            },
          ),

          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.rate_review_outlined),
            title: const Text('Rate App'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showRateAppDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildResetSection(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.restore,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(
          'Reset All Settings',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        subtitle: const Text('Reset all settings to default values'),
        onTap: () => _showResetDialog(context),
      ),
    );
  }

  Future<void> _showStreakGoalDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    int currentGoal = settingsProvider.streakGoal;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Set Streak Goal'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Choose your daily streak goal (1–365 days):'),
                    const SizedBox(height: 16),
                    Slider(
                      value: currentGoal.toDouble(),
                      min: 1,
                      max: 365,
                      divisions: 364,
                      label: '$currentGoal days',
                      onChanged: (value) {
                        setState(() {
                          currentGoal = value.toInt();
                        });
                      },
                    ),
                    Text('$currentGoal days'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, currentGoal),
                    child: const Text('Save'),
                  ),
                ],
              ),
        );
      },
    );

    if (result != null) {
      await settingsProvider.updateStreakGoal(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Streak goal updated to $result days')),
      );
    }
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    String selectedLanguage = settingsProvider.language;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Select Language'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        settingsProvider.availableLanguages.map((langCode) {
                          return RadioListTile<String>(
                            value: langCode,
                            groupValue: selectedLanguage,
                            title: Text(
                              settingsProvider.getLanguageName(langCode),
                            ),
                            onChanged: (value) {
                              setState(() {
                                selectedLanguage = value!;
                              });
                            },
                          );
                        }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, selectedLanguage),
                    child: const Text('Save'),
                  ),
                ],
              ),
        );
      },
    );

    if (result != null && result != settingsProvider.language) {
      await settingsProvider.updateLanguage(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Language changed to ${settingsProvider.getLanguageName(result)}',
          ),
        ),
      );
    }
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Settings'),
            content: const Text(
              'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );
      await settingsProvider.resetSettings();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to default values')),
        );
      }
    }
  }

  // Keep your existing dialog methods...
  void _showVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About Habit Tracker'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Version: 1.0.0'),
                SizedBox(height: 8),
                Text(
                  'Build your better habits with our simple and intuitive habit tracker.',
                ),
                SizedBox(height: 8),
                Text('© 2025 Habit Tracker App'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.help_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text('Help & Support'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How to use the app:'),
                SizedBox(height: 8),
                Text('• Tap the + button to add a new habit'),
                Text('• Tap on a habit to mark it as complete'),
                Text('• View your progress in the Statistics tab'),
                Text('• Long press on a habit to edit or delete it'),
                SizedBox(height: 16),
                Text('For more help, contact us at support@habittracker.com'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.privacy_tip, color: Colors.green),
                SizedBox(width: 8),
                Text('Privacy Policy'),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your privacy is important to us.'),
                  SizedBox(height: 8),
                  Text('• All data is stored locally on your device'),
                  Text('• We do not collect or share personal information'),
                  Text('• Notifications are processed locally'),
                  Text('• Analytics are anonymized and optional'),
                  SizedBox(height: 16),
                  Text('For the full privacy policy, visit our website.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showRateAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.star_rate, color: Colors.orange),
                SizedBox(width: 8),
                Text('Rate Our App'),
              ],
            ),
            content: const Text(
              'Enjoying Habit Tracker? Please take a moment to rate us on the app store!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement app store rating
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your feedback!'),
                    ),
                  );
                },
                child: const Text('Rate Now'),
              ),
            ],
          ),
    );
  }
}
