import 'package:flutter/material.dart';

class HabitProgressIndicator extends StatelessWidget {
  final double progress;
  final Color color;
  final String label;

  const HabitProgressIndicator({
    Key? key,
    required this.progress,
    required this.color,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
            ),
            Text(
              '${(clampedProgress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Semantics(
          label: '$label progress',
          value: '${(clampedProgress * 100).toInt()}%',
          child: LinearProgressIndicator(
            value: clampedProgress,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
