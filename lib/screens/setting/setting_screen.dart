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
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Settings', showBackButton: false),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Section (if user is authenticated)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isAuthenticated) {
                  return Column(
                    children: [
                      _buildProfileSection(context, authProvider),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Appearance Section
            const ThemeSelector(),
            const SizedBox(height: 24),

            // Notifications Section
            const NotificationSettings(),
            const SizedBox(height: 24),

            // Habits Configuration Section
            _buildHabitsSection(context),
            const SizedBox(height: 24),

            // Language Section
            _buildLanguageSection(context),
            const SizedBox(height: 24),

            // Data Management Section
            const BackupRestore(),
            const SizedBox(height: 24),

            // About Section
            _buildAboutSection(context),
            const SizedBox(height: 24),

            // Danger Zone
            _buildDangerZone(context),
            const SizedBox(height: 24),

            // Account Section (if authenticated)
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isAuthenticated) {
                  return _buildAccountSection(context, authProvider);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider) {
    final theme = Theme.of(context);
    final user = authProvider.currentUser;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: theme.colorScheme.primaryContainer,
              child:
                  user?.profilePicture != null
                      ? ClipOval(
                        child: Image.network(
                          user!.profilePicture!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  _buildInitialsAvatar(
                                    context,
                                    user.name ?? 'User',
                                  ),
                        ),
                      )
                      : _buildInitialsAvatar(context, user?.name ?? 'User'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'User',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? authProvider.userEmail ?? 'user@example.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Member since ${_formatDate(user?.createdAt ?? DateTime.now())}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: theme.colorScheme.primary),
              onPressed: () => _showEditProfileDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context, String name) {
    final theme = Theme.of(context);
    return Text(
      _getInitials(name),
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    List<String> names = name.split(' ');
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildHabitsSection(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habits Configuration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildSettingTile(
                  context: context,
                  icon: Icons.calendar_today,
                  title: 'Week Starts On',
                  subtitle:
                      settingsProvider.weekStartsOnMonday ? 'Monday' : 'Sunday',
                  trailing: Switch.adaptive(
                    value: settingsProvider.weekStartsOnMonday,
                    onChanged: (value) {
                      settingsProvider.toggleWeekStartsOnMonday();
                      _showFeedback(
                        context,
                        'Week now starts on ${value ? 'Monday' : 'Sunday'}',
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                _buildSettingTile(
                  context: context,
                  icon: Icons.local_fire_department,
                  title: 'Streak Goal',
                  subtitle: '${settingsProvider.streakGoal} days',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showStreakGoalDialog(context, settingsProvider),
                ),

                const SizedBox(height: 16),

                _buildSettingTile(
                  context: context,
                  icon: Icons.settings_backup_restore,
                  title: 'Auto Backup',
                  subtitle:
                      settingsProvider.autoBackup
                          ? 'Automatically backup data'
                          : 'Manual backup only',
                  trailing: Switch.adaptive(
                    value: settingsProvider.autoBackup,
                    onChanged: (value) {
                      settingsProvider.toggleAutoBackup();
                      _showFeedback(
                        context,
                        value ? 'Auto backup enabled' : 'Auto backup disabled',
                      );
                    },
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language & Region',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildSettingTile(
                  context: context,
                  icon: Icons.language,
                  title: 'App Language',
                  subtitle: settingsProvider.getLanguageName(
                    settingsProvider.language,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showLanguageDialog(context, settingsProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About & Support',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildSettingTile(
              context: context,
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showVersionDialog(context),
            ),

            const SizedBox(height: 8),

            _buildSettingTile(
              context: context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help using the app',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showHelpDialog(context),
            ),

            const SizedBox(height: 8),

            _buildSettingTile(
              context: context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPrivacyDialog(context),
            ),

            const SizedBox(height: 8),

            _buildSettingTile(
              context: context,
              icon: Icons.school_outlined,
              title: 'Show Tutorial',
              subtitle: 'Replay the app introduction',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                );
              },
            ),

            const SizedBox(height: 8),

            _buildSettingTile(
              context: context,
              icon: Icons.rate_review_outlined,
              title: 'Rate & Review',
              subtitle: 'Share your feedback',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showRateAppDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Danger Zone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSettingTile(
              context: context,
              icon: Icons.restart_alt,
              title: 'Reset All Settings',
              subtitle: 'Reset app to default configuration',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showResetDialog(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildSettingTile(
              context: context,
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: authProvider.userEmail ?? '',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showSignOutDialog(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final iconColor =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;
    final titleColor =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

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
                color:
                    isDestructive
                        ? theme.colorScheme.errorContainer.withOpacity(0.3)
                        : theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
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

  void _showEditProfileDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Profile'),
            content: Text('Profile editing feature coming soon!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  // Keep all your existing dialog methods but with improved styling
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
              title: Text('Set Streak Goal'),
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
                  ),
                  Text(
                    '$currentGoal days',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, currentGoal),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await settingsProvider.updateStreakGoal(result);
      _showFeedback(context, 'Streak goal updated to $result days');
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
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedLanguage),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result != settingsProvider.language) {
      await settingsProvider.updateLanguage(result);
      _showFeedback(
        context,
        'Language changed to ${settingsProvider.getLanguageName(result)}',
      );
    }
  }

  Future<void> _showResetDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Reset Settings'),
            content: const Text(
              'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
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
        _showFeedback(context, 'Settings reset to default values');
      }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Sign Out'),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text('Help & Support'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to use the app:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '• Tap the + button to add a new habit\n'
                  '• Tap on a habit to mark it as complete\n'
                  '• View your progress in the Statistics tab\n'
                  '• Long press on a habit to edit or delete it',
                ),
                SizedBox(height: 16),
                Text(
                  'For more help, contact us at support@habittracker.com',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.privacy_tip, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Privacy Policy'),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your privacy is important to us.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• All data is stored locally on your device\n'
                    '• We do not collect or share personal information\n'
                    '• Notifications are processed locally\n'
                    '• Analytics are anonymized and optional',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'For the full privacy policy, visit our website.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.star_rate, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Rate Our App'),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                    );
                    _showFeedback(context, 'Thank you for your feedback!');
                  });
                },
                child: const Text('Rate Now'),
              ),
            ],
          ),
    );
  }
}

