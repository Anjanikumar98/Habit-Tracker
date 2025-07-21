import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/auth_provider.dart';
import 'package:habit_tracker/providers/settings_provider.dart';
import 'package:habit_tracker/screens/authentication_screen/feedback_screen.dart';
import 'package:habit_tracker/screens/authentication_screen/login_screen.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

            // _buildSectionHeader(context, 'Data'),
            // const BackupRestore(),
            // const SizedBox(height: 24),
            _buildSectionHeader(context, 'About'),
            _buildAboutSection(context),
            const SizedBox(height: 24),

            _buildResetSection(context),
            const SizedBox(height: 24),

            _buildSectionHeader(context, 'Account'),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ListTile(
                  leading: Icon(Icons.logout, color: colorScheme.error),
                  title: Text(
                    'Sign Out',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    authProvider.userEmail ?? '',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  onTap: () => _showSignOutDialog(context),
                );
              },
            ),
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
    final theme = Theme.of(context);

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: theme.colorScheme.surface, // theme-aware background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    'Week Starts On',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    settingsProvider.weekStartsOnMonday ? 'Monday' : 'Sunday',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Switch(
                    value: settingsProvider.weekStartsOnMonday,
                    onChanged:
                        (value) => settingsProvider.toggleWeekStartsOnMonday(),
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.local_fire_department,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    'Streak Goal',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${settingsProvider.streakGoal} days',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showStreakGoalDialog(context, settingsProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.settings_backup_restore,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    'Auto Backup',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Automatically backup data',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Switch(
                    value: settingsProvider.autoBackup,
                    onChanged: (value) => settingsProvider.toggleAutoBackup(),
                    activeColor: theme.colorScheme.primary,
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
    final theme = Theme.of(context);

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.language, color: theme.colorScheme.primary),
            title: Text(
              'Language',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              settingsProvider.getLanguageName(settingsProvider.language),
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context, settingsProvider),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          _buildThemedTile(
            context,
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: () => _showVersionDialog(context),
          ),
          const Divider(height: 1),
          _buildThemedTile(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => _showHelpDialog(context),
          ),
          const Divider(height: 1),
          _buildThemedTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _showPrivacyDialog(context),
          ),
          const Divider(height: 1),
          _buildThemedTile(
            context,
            icon: Icons.help_outline,
            title: 'Show Onboarding',
            subtitle: 'Replay the app introduction',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            },
          ),
          const Divider(height: 1),
          _buildThemedTile(
            context,
            icon: Icons.rate_review_outlined,
            title: 'Rate App',
            onTap: () => _showRateAppDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildThemedTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle:
          subtitle != null
              ? Text(subtitle, style: theme.textTheme.bodySmall)
              : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildResetSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.restore, color: theme.colorScheme.error),
        title: Text(
          'Reset All Settings',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Reset all settings to default values',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
          ),
        ),
        onTap: () => _showResetDialog(context),
      ),
    );
  }

  Future<void> _showStreakGoalDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    int currentGoal = settingsProvider.streakGoal;
    final theme = Theme.of(context);

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Set Streak Goal',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose your daily streak goal (1–365 days):',
                    style: theme.textTheme.bodyMedium,
                  ),
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
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  Text('$currentGoal days', style: theme.textTheme.titleMedium),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, currentGoal),
                  child: Text(
                    'Save',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await settingsProvider.updateStreakGoal(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Streak goal updated to $result days'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    String selectedLanguage = settingsProvider.language;
    final theme = Theme.of(context);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Select Language',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
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
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          activeColor: theme.colorScheme.primary,
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, selectedLanguage),
                  child: Text(
                    'Save',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            );
          },
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
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.colorScheme.surface,
            title: Text(
              'Reset Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            content: Text(
              'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
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
          SnackBar(
            content: const Text('Settings reset to default values'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: theme.colorScheme.surfaceVariant,
          ),
        );
      }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.colorScheme.surface,
            title: Text(
              'Sign Out',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            content: Text(
              'Are you sure you want to sign out?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.signOut();

                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }

  // Keep your existing dialog methods...
  void _showVersionDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.colorScheme.surface,
            title: Text(
              'About Habit Tracker',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version: 1.0.0',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Build your better habits with our simple and intuitive habit tracker.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 Habit Tracker App',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.colorScheme.surface,
            title: Row(
              children: [
                Icon(Icons.help_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Help & Support',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to use the app:',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Tap the + button to add a new habit\n'
                  '• Tap on a habit to mark it as complete\n'
                  '• View your progress in the Statistics tab\n'
                  '• Long press on a habit to edit or delete it',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'For more help, contact us at support@habittracker.com',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.colorScheme.surface,
            title: Row(
              children: [
                Icon(Icons.privacy_tip, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Privacy Policy',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your privacy is important to us.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• All data is stored locally on your device\n'
                    '• We do not collect or share personal information\n'
                    '• Notifications are processed locally\n'
                    '• Analytics are anonymized and optional',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'For the full privacy policy, visit our website.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
    );
  }

  void _showRateAppDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: theme.colorScheme.surface,
            title: Row(
              children: [
                const Icon(Icons.star_rate, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Rate Our App',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            content: Text(
              'Enjoying Habit Tracker? Please take a moment to rate us on the app store!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Later',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  // Schedule the navigation & snackbar after the current frame
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Thank you for your feedback!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onInverseSurface,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.inverseSurface,
                      ),
                    );
                  });
                },
                child: Text(
                  'Rate Now',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
    );
  }
}


