import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool isActive;

  const StreakBadge({super.key, required this.streak, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    final theme = Theme.of(context);

    // Colors & styles
    final badgeGradient =
        isActive
            ? const LinearGradient(
              colors: [Colors.deepOrange, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
            : LinearGradient(colors: [Colors.grey[300]!, Colors.grey[400]!]);

    final iconColor = isActive ? Colors.white : Colors.black54;
    final textColor = isActive ? Colors.white : Colors.black87;

    return Tooltip(
      message: '🔥 Current streak: $streak day${streak > 1 ? 's' : ''}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: badgeGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: iconColor,
              size: 16,
              semanticLabel: 'Flame icon for streak',
            ),
            const SizedBox(width: 5),
            Text(
              '$streak',
              style: theme.textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

