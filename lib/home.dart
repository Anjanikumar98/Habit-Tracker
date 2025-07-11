import 'package:flutter/material.dart';
import 'items.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> userHabits = [
    {
      'color': const Color(0xff7524ff),
      'title': 'Learn 5 new words',
      'progress': '5 from 7 this week',
      'progressValue': 5 / 7,
    },
    {
      'color': const Color(0xfff03244),
      'title': 'Get Up Early',
      'progress': '3 from 7 this week',
      'progressValue': 3 / 7,
    },
  ];

  void addHabit() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController progressController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Habit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Habit Title'),
            ),
            TextField(
              controller: progressController,
              decoration: const InputDecoration(labelText: 'Days completed (e.g. 3/7)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                final title = titleController.text.trim();
                final progressParts = progressController.text.trim().split('/');
                int done = int.tryParse(progressParts[0]) ?? 0;
                int total = progressParts.length > 1 ? int.tryParse(progressParts[1]) ?? 7 : 7;

                if (title.isNotEmpty) {
                  Navigator.pop(ctx, {
                    'title': title,
                    'progress': '$done from $total this week',
                    'progressValue': done / total,
                    'color': Colors.primaries[userHabits.length % Colors.primaries.length],
                  });
                }
              },
              child: const Text("Add")),
        ],
      ),
    );

    if (result != null) {
      setState(() => userHabits.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff131b26),
      appBar: AppBar(
        title: const Text("Your Habits"),
        backgroundColor: const Color(0xff131b26),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff6f1bff),
        child: const Icon(Icons.add),
        onPressed: addHabit,
      ),
      body: ListView.builder(
        itemCount: userHabits.length,
        itemBuilder: (ctx, index) {
          return ListItem(id: index, habit: userHabits[index]);
        },
      ),
    );
  }
}
