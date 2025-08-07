import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/habit.dart';
import '../../../providers/habit_provider.dart';
import '../../../utlis/constants.dart';
import 'frequency_selector.dart';

class HabitForm extends StatefulWidget {
  final Habit? habit;

  const HabitForm({super.key, this.habit});

  @override
  State<HabitForm> createState() => _HabitFormState();
}

class _HabitFormState extends State<HabitForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = Constants.categories.first;
  String _selectedFrequency = Constants.frequencies.first;
  Color _selectedColor = Constants.habitColorList.first;
  TimeOfDay? _reminderTime;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _descriptionController.text = widget.habit!.description;
      _selectedCategory = widget.habit!.category;
      _selectedFrequency = widget.habit!.frequency;
      _selectedColor = widget.habit!.color;
      _reminderTime = widget.habit!.reminderTime;
      _tags = List.from(widget.habit!.tags);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Name Field
            _buildNameField(),

            const SizedBox(height: 16),

            // Description Field
            _buildDescriptionField(),

            const SizedBox(height: 16),

            // Category Dropdown
            _buildCategoryDropdown(),

            const SizedBox(height: 16),

            // Frequency Selector
            FrequencySelector(
              selectedFrequency: _selectedFrequency,
              onFrequencyChanged: (frequency) {
                setState(() => _selectedFrequency = frequency);
              },
            ),

            const SizedBox(height: 16),

            // Color Picker
            _buildColorSelector(),

            const SizedBox(height: 16),

            // Reminder Time Picker
            _buildReminderTimeSelector(),

            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: _nameController,
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Habit Name',
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        hintText: 'Enter habit name',
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
        prefixIcon: Icon(Icons.edit, color: colorScheme.primary),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        counterStyle: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
      ),
      maxLength: Constants.maxHabitNameLength,
      validator:
          (value) =>
              value == null || value.trim().isEmpty ? 'Name required' : null,
    );
  }

  Widget _buildDescriptionField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextFormField(
      controller: _descriptionController,
      maxLength: Constants.maxDescriptionLength,
      maxLines: 3,
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        hintText: 'Add some details...',
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
        prefixIcon: Icon(Icons.description, color: colorScheme.primary),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        counterStyle: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        hintText: 'Select a category',
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
        prefixIcon: Icon(Icons.category, color: colorScheme.primary),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      dropdownColor: colorScheme.surface,
      iconEnabledColor: colorScheme.onSurface,
      items:
          Constants.categories
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
      validator: (value) => value == null ? 'Category required' : null,
    );
  }

  Widget _buildColorSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              Constants.habitColorList.map((color) {
                final isSelected = _selectedColor == color;

                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected
                                ? colorScheme.primary
                                : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : [],
                    ),
                    child:
                        isSelected
                            ? Icon(
                              Icons.check,
                              color: colorScheme.onPrimary,
                              size: 20,
                            )
                            : null,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildReminderTimeSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isSet = _reminderTime != null;

    return Card(
      margin: const EdgeInsets.only(top: 4),
      shape: theme.cardTheme.shape,
      color: colorScheme.surfaceContainerHighest,
      elevation: theme.cardTheme.elevation,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.alarm, color: colorScheme.primary),
        title: Text(
          'Reminder Time',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          isSet ? _reminderTime!.format(context) : 'Not set',
          style: textTheme.bodyMedium?.copyWith(
            color: isSet ? colorScheme.onSurface : colorScheme.outline,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: _reminderTime ?? TimeOfDay.now(),
            builder: (context, child) {
              return Theme(
                data: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: theme.colorScheme.primary,
                    onPrimary: theme.colorScheme.onPrimary,
                    surface: theme.colorScheme.surface,
                    onSurface: theme.colorScheme.onSurface,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (time != null) {
            setState(() => _reminderTime = time);
          }
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: theme.elevatedButtonTheme.style, // Use theme style
        child: Text(
          widget.habit == null ? 'Create Habit' : 'Update Habit',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    final newHabit = Habit(
      id: widget.habit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      frequency: _selectedFrequency,
      color: _selectedColor,
      reminderTime: _reminderTime,
      tags: _tags,
      createdAt: widget.habit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      completions: [],
    );

    final habitProvider = context.read<HabitProvider>();

    if (widget.habit == null) {
      habitProvider.addHabit(newHabit);
      _showSnackBar(context, 'Habit created successfully 🎉');
    } else {
      habitProvider.updateHabit(newHabit);
      _showSnackBar(context, 'Habit updated ✅');
    }

    Navigator.pop(context);
  }

  void _showSnackBar(BuildContext context, String message) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
