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
    final Color effectiveColor = color;
    final Color borderColor = isCompleted ? effectiveColor : Colors.grey.shade500;
    final Color iconColor = isCompleted ? Colors.white : Colors.grey.shade600;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted ? effectiveColor : Colors.transparent,
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}
