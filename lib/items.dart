import 'package:flutter/material.dart';
import 'main.dart'; // Make sure this contains your habits2 list

class ListItem extends StatelessWidget {
  final int id;
  final Map<String, dynamic> habit;

  const ListItem({Key? key, required this.id, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isChecked = habit['progressValue'] >= 1.0;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/details', arguments: habit);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        padding: const EdgeInsets.only(right: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChecked ? habit['color'] : Colors.transparent,
                    border: Border.all(
                      color: isChecked ? habit['color'] : Colors.grey.shade500,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    color: isChecked ? Colors.white : Colors.grey.shade500,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit['title'] ?? 'Habit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      habit['progress'] ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: habit['progressValue'] ?? 0.0,
              backgroundColor: const Color(0xff1c232d),
              valueColor: AlwaysStoppedAnimation<Color>(
                habit['color'] ?? Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
