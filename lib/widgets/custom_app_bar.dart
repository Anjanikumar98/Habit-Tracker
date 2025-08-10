import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: showBackButton ? const BackButton() : leading,
      actions: actions,
      centerTitle: true,
      bottom: bottom,
      elevation: appBarTheme.elevation ?? 0,
      shadowColor: appBarTheme.shadowColor ?? Colors.black.withOpacity(0.15),
      backgroundColor: appBarTheme.backgroundColor ?? theme.colorScheme.primary,
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}
