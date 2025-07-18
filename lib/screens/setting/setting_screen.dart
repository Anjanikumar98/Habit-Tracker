import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/setting/widgets/backup_restore.dart';
import 'package:habit_tracker/screens/setting/widgets/notification_settings.dart';
import 'package:habit_tracker/screens/setting/widgets/theme_selector.dart';
import '../../widgets/custom_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // _buildSectionHeader(context, 'Data'),
          // const BackupRestore(),
          // const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          _buildAboutSection(context),
        ],
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
            leading: const Icon(Icons.rate_review_outlined),
            title: const Text('Rate App'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showRateAppDialog(context),
          ),
        ],
      ),
    );
  }

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
                Text('© 2024 Habit Tracker App'),
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
            title: const Text('Help & Support'),
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
            title: const Text('Privacy Policy'),
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
            title: const Text('Rate Our App'),
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
