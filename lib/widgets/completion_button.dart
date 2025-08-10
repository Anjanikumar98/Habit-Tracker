import 'package:flutter/material.dart';

class CompletionButton extends StatelessWidget {
  final bool isCompleted;
  final Color color;
  final VoidCallback onPressed;

  const CompletionButton({
    super.key,
    required this.isCompleted,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isCompleted ? color : Colors.grey.shade500;
    final iconColor = isCompleted ? Colors.white : Colors.grey.shade600;

    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      splashColor: color.withOpacity(0.2),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isCompleted ? color : Colors.transparent,
          border: Border.all(color: borderColor, width: 2),
          shape: BoxShape.circle,
          boxShadow:
              isCompleted
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                  : [],
        ),
        child: AnimatedScale(
          scale: isCompleted ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Icon(Icons.check, color: iconColor, size: 22),
        ),
      ),
    );
  }
}
