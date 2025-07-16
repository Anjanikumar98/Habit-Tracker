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
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            FrequencySelector(
              selectedFrequency: _selectedFrequency,
              onFrequencyChanged: (frequency) {
                setState(() => _selectedFrequency = frequency);
              },
            ),
            const SizedBox(height: 16),
            _buildColorSelector(),
            const SizedBox(height: 16),
            _buildReminderTimeSelector(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Habit Name',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.edit),
      ),
      validator:
          (value) => value == null || value.isEmpty ? 'Name required' : null,
      maxLength: Constants.maxHabitNameLength,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLength: Constants.maxDescriptionLength,
      maxLines: 3,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items:
          Constants.categories
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
      validator: (value) => value == null ? 'Category required' : null,
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              Constants.habitColorList.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child:
                        isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildReminderTimeSelector() {
    return ListTile(
      leading: const Icon(Icons.alarm),
      title: const Text('Reminder Time'),
      subtitle: Text(_reminderTime?.format(context) ?? 'Not set'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _reminderTime ?? TimeOfDay.now(),
        );
        if (time != null) {
          setState(() => _reminderTime = time);
        }
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        child: Text(widget.habit == null ? 'Create Habit' : 'Update Habit'),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id:
            widget.habit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        frequency: _selectedFrequency,
        color: _selectedColor,
        reminderTime: _reminderTime,
        tags: _tags,
        createdAt: widget.habit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final provider = context.read<HabitProvider>();
      if (widget.habit == null) {
        provider.addHabit(habit);
      } else {
        provider.updateHabit(habit);
      }

      Navigator.pop(context);
    }
  }
}
