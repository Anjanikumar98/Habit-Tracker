import 'package:flutter/material.dart';

class BackupRestore extends StatelessWidget {
  const BackupRestore({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement backup functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup not implemented')),
            );
          },
          icon: const Icon(Icons.backup),
          label: const Text('Backup Data'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement restore functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Restore not implemented')),
            );
          },
          icon: const Icon(Icons.restore),
          label: const Text('Restore Data'),
        ),
      ],
    );
  }
}
