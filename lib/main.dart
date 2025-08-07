import 'package:flutter/material.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/providers/settings_provider.dart';
import 'package:habit_tracker/providers/auth_provider.dart';
import 'package:habit_tracker/screens/home/home_screen.dart';
import 'package:habit_tracker/screens/onboarding/onboarding_screen.dart';
import 'package:habit_tracker/screens/authentication_screen/login_screen.dart';
import 'package:habit_tracker/screens/splash_screen.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:habit_tracker/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  try {
    await NotificationService().initialize();

    // Initialize database (this will create tables if they don't exist)
    final databaseService = DatabaseService();
    await databaseService.database; // This triggers database initialization

    print('✅ Services initialized successfully');
  } catch (e) {
    print('❌ Error initializing services: $e');
  }

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Habit Tracker',

            // Use the theme provider's methods
            theme: themeProvider.getLightTheme(),
            darkTheme: themeProvider.getDarkTheme(),
            themeMode: themeProvider.themeMode,

            debugShowCheckedModeBanner: false,
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _isFirstTime = true;
  bool _isAuthenticated = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;

      // Initialize all providers
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(
        context,
        listen: false,
      );

      // Initialize AuthProvider first
      await authProvider.initialize();

      // Check authentication status
      final isAuthenticated = authProvider.isAuthenticated;

      // Initialize other providers if user is authenticated
      if (isAuthenticated) {
        await habitProvider.initialize();
        await settingsProvider.loadSettings();

        // Set up cross-provider relationships
        settingsProvider.setHabitProvider(habitProvider);
      }

      // Add a slight delay for better UX
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _isFirstTime = isFirstTime;
          _isAuthenticated = isAuthenticated;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error initializing app: $e');

      if (mounted) {
        setState(() {
          _isFirstTime = true;
          _isAuthenticated = false;
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    // Show error screen if there was an initialization error
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),

              SizedBox(height: 16),
              Text(
                'Initialization Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 31),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _initializeApp();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isFirstTime) {
      return const OnboardingScreen();
    } else if (!_isAuthenticated) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}
