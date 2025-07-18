import 'package:flutter/material.dart';
import 'package:habit_tracker/services/api_services/motivational_service.dart';

class MotivationCard extends StatelessWidget {
  const MotivationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: MotivationalService.getMotivationalQuote(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Failed to load motivation 😢');
        } else if (!snapshot.hasData) {
          return const Text('No motivation available.');
        }

        final quote = snapshot.data!;
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ListTile(
            leading: const Icon(Icons.format_quote, color: Colors.deepPurple),
            title: Text(
              '"${quote['text']}"',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            subtitle: Text('- ${quote['author']}'),
          ),
        );
      },
    );
  }
}
