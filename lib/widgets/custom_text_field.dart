import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isPasswordVisible;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
      HapticFeedback.selectionClick();
    } else {
      _animationController.reverse();
      // Validate on focus lost
      if (widget.validator != null) {
        final error = widget.validator!(widget.controller.text);
        setState(() {
          _hasError = error != null;
          _errorText = error;
        });
      }
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dynamic border color based on state
    Color borderColor;
    if (_hasError) {
      borderColor = Colors.red;
    } else if (_isFocused) {
      borderColor = colorScheme.primary;
    } else {
      borderColor = colorScheme.outline.withOpacity(0.5);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  _hasError
                      ? Colors.red
                      : colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),

        // Text Field with Animation
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      _isFocused
                          ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword && !widget.isPasswordVisible,
                  textInputAction: widget.textInputAction,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  onChanged: (value) {
                    // Clear error when user starts typing
                    if (_hasError && value.isNotEmpty) {
                      setState(() {
                        _hasError = false;
                        _errorText = null;
                      });
                    }
                    widget.onChanged?.call(value);
                  },
                  enabled: widget.enabled,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  autofocus: widget.autofocus,
                  textCapitalization: widget.textCapitalization,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color:
                        widget.enabled
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withOpacity(0.5),
                  ),
                  validator: (value) {
                    final error = widget.validator?.call(value);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _hasError = error != null;
                          _errorText = error;
                        });
                      }
                    });
                    return error;
                  },
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    prefixIcon:
                        widget.prefixIcon != null
                            ? Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Icon(
                                widget.prefixIcon,
                                color:
                                    _hasError
                                        ? Colors.red
                                        : _isFocused
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withOpacity(
                                          0.6,
                                        ),
                                size: 20,
                              ),
                            )
                            : null,
                    suffixIcon: widget.suffixIcon,
                    filled: true,
                    fillColor:
                        widget.enabled
                            ? _isFocused
                                ? colorScheme.surface
                                : colorScheme.surface.withOpacity(0.8)
                            : colorScheme.onSurface.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    counterText: widget.maxLength != null ? '' : null,
                    errorStyle: const TextStyle(
                      height: 0.01,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Error Message with Animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _hasError ? 24 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _hasError ? 1.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _errorText ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Character count for fields with maxLength
        if (widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${widget.controller.text.length}/${widget.maxLength}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      widget.controller.text.length > (widget.maxLength! * 0.9)
                          ? Colors.orange
                          : colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
