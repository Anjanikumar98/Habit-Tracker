import 'package:flutter/material.dart';
import 'details.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      home: Home(),
      routes: {
        '/details': (context) => Details(),
      },
    );
  }
}
