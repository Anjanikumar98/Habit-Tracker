import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/theme_provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Theme Mode Selection
                _buildSettingTile(
                  context: context,
                  icon: themeProvider.getThemeModeIcon(),
                  title: 'Theme Mode',
                  subtitle: themeProvider.getThemeModeDisplayName(),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeProvider.themeMode,
                    underline: const SizedBox(),
                    onChanged: (ThemeMode? newThemeMode) {
                      if (newThemeMode != null) {
                        themeProvider.setThemeMode(newThemeMode);
                        _showThemeFeedback(context, newThemeMode);
                      }
                    },
                    items:
                        ThemeMode.values.map((ThemeMode themeMode) {
                          return DropdownMenuItem<ThemeMode>(
                            value: themeMode,
                            child: Text(_getThemeName(themeMode)),
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Font Size Selection
                _buildSettingTile(
                  context: context,
                  icon: Icons.text_fields,
                  title: 'Font Size',
                  subtitle: themeProvider.getFontSizeDisplayName(),
                  trailing: DropdownButton<double>(
                    value: themeProvider.fontSize,
                    underline: const SizedBox(),
                    onChanged: (double? newFontSize) {
                      if (newFontSize != null) {
                        themeProvider.setFontSize(newFontSize);
                        _showFontSizeFeedback(context, newFontSize);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 0.8, child: Text('Small')),
                      DropdownMenuItem(value: 1.0, child: Text('Normal')),
                      DropdownMenuItem(value: 1.2, child: Text('Large')),
                      DropdownMenuItem(value: 1.4, child: Text('Extra Large')),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Accent Color Selection
                _buildSettingTile(
                  context: context,
                  icon: Icons.palette,
                  title: 'Accent Color',
                  subtitle: _getColorName(themeProvider.accentColor),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: themeProvider.accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () => _showColorPicker(context, themeProvider),
                ),

                const SizedBox(height: 24),

                // Theme Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.preview,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Preview',
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPreviewCard(context, themeProvider),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showResetDialog(context, themeProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset to Defaults'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildPreviewCard(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sample Habit',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Icon(
                Icons.check_circle,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This is how your habits will look with the current theme settings.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'Follow System';
    }
  }

  String _getColorName(Color color) {
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.green) return 'Green';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.red) return 'Red';
    if (color == Colors.teal) return 'Teal';
    if (color == Colors.indigo) return 'Indigo';
    if (color == Colors.pink) return 'Pink';
    return 'Custom';
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Choose Accent Color'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children:
                  [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.red,
                    Colors.teal,
                    Colors.indigo,
                    Colors.pink,
                  ].map((color) {
                    final isSelected =
                        themeProvider.accentColor.value == color.value;
                    return GestureDetector(
                      onTap: () async {
                        await themeProvider.setAccentColor(color);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Accent color changed to ${_getColorName(color)}',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border:
                              isSelected
                                  ? Border.all(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 3,
                                  )
                                  : Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                        ),
                        child:
                            isSelected
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                                : null,
                      ),
                    );
                  }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Reset Theme Settings'),
            content: const Text(
              'This will reset all appearance settings to their default values. Are you sure you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await themeProvider.resetToDefaults();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Theme settings reset to defaults'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  void _showThemeFeedback(BuildContext context, ThemeMode themeMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme changed to ${_getThemeName(themeMode)}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFontSizeFeedback(BuildContext context, double fontSize) {
    String sizeName;
    if (fontSize <= 0.8) {
      sizeName = 'Small';
    } else if (fontSize <= 1.0) {
      sizeName = 'Normal';
    } else if (fontSize <= 1.2) {
      sizeName = 'Large';
    } else {
      sizeName = 'Extra Large';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Font size changed to $sizeName'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
