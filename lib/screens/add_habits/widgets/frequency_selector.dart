import 'package:flutter/material.dart';
import '../../../utlis/constants.dart';

class FrequencySelector extends StatelessWidget {
  final String selectedFrequency;
  final ValueChanged<String> onFrequencyChanged;

  const FrequencySelector({
    super.key,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              Constants.frequencies.map((frequency) {
                final isSelected = selectedFrequency == frequency;
                return _buildFrequencyChip(
                  frequency: frequency,
                  isSelected: isSelected,
                  onTap: () => onFrequencyChanged(frequency),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildFrequencyChip({
    required String frequency,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Tooltip(
      message: 'Set habit frequency to "$frequency"',
      child: ChoiceChip(
        label: Text(
          frequency,
          style: textTheme.labelLarge?.copyWith(
            color:
                isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color:
                isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
