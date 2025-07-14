import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/home/home_screen.dart';
import 'package:habit_tracker/utlis/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => HabitProvider()),
        // ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      // child: Consumer<ThemeProvider>(
      //   builder: (context, themeProvider, child) {
      //     return MaterialApp(
      //       title: 'Habit Tracker',
      //       debugShowCheckedModeBanner: false,
      //       theme: AppTheme.darkTheme,
      //       initialRoute: '/',
      //       routes: {
      //         '/': (context) => MainScreen(),
      //         '/add-habit': (context) => AddHabitScreen(),
      //         '/habit-detail': (context) => HabitDetailScreen(),
      //         '/statistics': (context) => StatisticsScreen(),
      //         '/settings': (context) => SettingsScreen(),
      //       },
      //     );
      //   },
      // ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    // StatisticsScreen(),
    // SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
