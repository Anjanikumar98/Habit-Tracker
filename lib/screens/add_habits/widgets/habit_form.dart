// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../models/habit.dart';
// import '../../../providers/habit_provider.dart';
// import '../../../utlis/constants.dart';
// import 'frequency_selector.dart';
//
// class HabitForm extends StatefulWidget {
//   final Habit? habit;
//
//   const HabitForm({super.key, this.habit});
//
//   @override
//   State<HabitForm> createState() => _HabitFormState();
// }
//
// class _HabitFormState extends State<HabitForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _descriptionController = TextEditingController();
//
//   String _selectedCategory = Constants.categories.first;
//   String _selectedFrequency = Constants.frequencies.first;
//   String _selectedColor = Constants.habitColors.first;
//   TimeOfDay? _targetTime;
//   List<String> _tags = [];
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.habit != null) {
//       _nameController.text = widget.habit!.name;
//       _descriptionController.text = widget.habit!.description;
//       _selectedCategory = widget.habit!.category;
//       _selectedFrequency = widget.habit!.frequency;
//       _selectedColor = widget.habit!.color;
//       _tags = List.from(widget.habit!.tags);
//       if (widget.habit!.targetTime != null) {
//         _targetTime = TimeOfDay.fromDateTime(widget.habit!.targetTime!);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildNameField(),
//             const SizedBox(height: 16),
//             _buildDescriptionField(),
//             const SizedBox(height: 16),
//             _buildCategoryDropdown(),
//             const SizedBox(height: 16),
//             FrequencySelector(
//               selectedFrequency: _selectedFrequency,
//               onFrequencyChanged: (frequency) {
//                 setState(() => _selectedFrequency = frequency);
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildColorSelector(),
//             const SizedBox(height: 16),
//             _buildTargetTimeSelector(),
//             const SizedBox(height: 24),
//             _buildSubmitButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNameField() {
//     return TextFormField(
//       controller: _nameController,
//       decoration: const InputDecoration(
//         labelText: 'Habit Name',
//         border: OutlineInputBorder(),
//         prefixIcon: Icon(Icons.edit),
//       ),
//       validator: Validators.validateHabitName,
//       maxLength: Constants.maxHabitNameLength,
//     );
//   }
//
//   Widget _buildDescriptionField() {
//     return TextFormField(
//       controller: _descriptionController,
//       decoration: const InputDecoration(
//         labelText: 'Description (Optional)',
//         border: OutlineInputBorder(),
//         prefixIcon: Icon(Icons.description),
//       ),
//       validator: Validators.validateDescription,
//       maxLength: Constants.maxDescriptionLength,
//       maxLines: 3,
//     );
//   }
//
//   Widget _buildCategoryDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedCategory,
//       decoration: const InputDecoration(
//         labelText: 'Category',
//         border: OutlineInputBorder(),
//         prefixIcon: Icon(Icons.category),
//       ),
//       items:
//           Constants.categories.map((category) {
//             return DropdownMenuItem(value: category, child: Text(category));
//           }).toList(),
//       onChanged: (value) {
//         setState(() => _selectedCategory = value!);
//       },
//       validator: Validators.validateCategory,
//     );
//   }
//
//   Widget _buildColorSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Color',
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           children:
//               Constants.habitColors.map((color) {
//                 final isSelected = _selectedColor == color;
//                 return GestureDetector(
//                   onTap: () => setState(() => _selectedColor = color),
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Color(
//                         int.parse(color.substring(1), radix: 16) + 0xFF000000,
//                       ),
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: isSelected ? Colors.black : Colors.transparent,
//                         width: 2,
//                       ),
//                     ),
//                     child:
//                         isSelected
//                             ? const Icon(Icons.check, color: Colors.white)
//                             : null,
//                   ),
//                 );
//               }).toList(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTargetTimeSelector() {
//     return ListTile(
//       leading: const Icon(Icons.access_time),
//       title: const Text('Target Time'),
//       subtitle: Text(_targetTime?.format(context) ?? 'Not set'),
//       trailing: const Icon(Icons.arrow_forward_ios),
//       onTap: () async {
//         final time = await showTimePicker(
//           context: context,
//           initialTime: _targetTime ?? TimeOfDay.now(),
//         );
//         if (time != null) {
//           setState(() => _targetTime = time);
//         }
//       },
//     );
//   }
//
//   Widget _buildSubmitButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _submitForm,
//         child: Text(widget.habit == null ? 'Create Habit' : 'Update Habit'),
//       ),
//     );
//   }
//
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       final habit = Habit(
//         id:
//             widget.habit?.id ??
//             DateTime.now().millisecondsSinceEpoch.toString(),
//         name: _nameController.text,
//         description: _descriptionController.text,
//         category: _selectedCategory,
//         frequency: _selectedFrequency,
//         createdAt: widget.habit?.createdAt ?? DateTime.now(),
//         targetTime:
//             _targetTime != null
//                 ? DateTime(2024, 1, 1, _targetTime!.hour, _targetTime!.minute)
//                 : null,
//         color: _selectedColor,
//         tags: _tags,
//         currentStreak: widget.habit?.currentStreak ?? 0,
//         longestStreak: widget.habit?.longestStreak ?? 0,
//         totalCompletions: widget.habit?.totalCompletions ?? 0,
//       );
//
//       if (widget.habit == null) {
//         context.read<HabitProvider>().addHabit(habit);
//       } else {
//         context.read<HabitProvider>().updateHabit(habit);
//       }
//
//       Navigator.pop(context);
//     }
//   }
// }
