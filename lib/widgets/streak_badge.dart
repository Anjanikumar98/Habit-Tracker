import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool isActive;

  const StreakBadge({Key? key, required this.streak, required this.isActive})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final badgeColor = isActive ? Colors.orange : Colors.grey[300];
    final iconColor = isActive ? Colors.white : Colors.black54;
    final textColor = isActive ? Colors.white : Colors.black87;

    return Tooltip(
      message: 'Current streak: $streak day(s)',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: iconColor,
              size: 14,
              semanticLabel: 'Flame icon for streak',
            ),
            const SizedBox(width: 4),
            Text(
              '$streak',
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
