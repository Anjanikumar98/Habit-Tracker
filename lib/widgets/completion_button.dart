import 'package:flutter/material.dart';

class CompletionButton extends StatelessWidget {
  final bool isCompleted;
  final Color color;
  final VoidCallback onPressed;

  const CompletionButton({
    Key? key,
    required this.isCompleted,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.transparent,
            border: Border.all(
              color: isCompleted ? color : Colors.grey[600]!,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: isCompleted ? Colors.white : Colors.grey[600],
            size: 18,
          ),
        ),
      ),
    );
  }
}
