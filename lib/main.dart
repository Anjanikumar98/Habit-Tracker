import 'package:flutter/material.dart';

import 'details.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      routes: {'/details': (context) => Details()},
    );
  }
}

List<Map<String, dynamic>> habits = [
  {'color': Colors.blue, 'title': 'YP', 'fulltext': 'Yoga Practice'},
  {'color': Colors.red, 'title': 'GE', 'fulltext': 'Get Up Early'},
  {'color': Colors.cyan, 'title': 'NS', 'fulltext': 'No Sugar'},
];

List<Map<String, dynamic>> habits2 = [
  {
    'color': Color(0xff7524ff),
    'objectif': 'Learn 5 new words',
    'progress': '5 from 7 this week',
  },
  {
    'color': Color(0xfff03244),
    'objectif': 'Get Up Early',
    'progress': '5 from 7 this week',
  },
  {
    'color': Color(0xff00d5e2),
    'objectif': 'Create an App a day',
    'progress': '6 from 7 this week',
  },
];
