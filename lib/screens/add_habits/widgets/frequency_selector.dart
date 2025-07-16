import 'package:flutter/material.dart';
import '../../../utlis/constants.dart';

class FrequencySelector extends StatelessWidget {
  final String selectedFrequency;
  final Function(String) onFrequencyChanged;

  const FrequencySelector({
    Key? key,
    required this.selectedFrequency,
    required this.onFrequencyChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequency',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              Constants.frequencies.map((frequency) {
                final isSelected = selectedFrequency == frequency;
                return ChoiceChip(
                  label: Text(frequency),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onFrequencyChanged(frequency);
                    }
                  },
                );
              }).toList(),
        ),
      ],
    );
  }
}
