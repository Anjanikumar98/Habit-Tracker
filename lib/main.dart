import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Set preferred orientations (optional - keeps app portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize core services with better error handling
  try {
    // Initialize notification service
    await NotificationService().initialize();
    debugPrint('✅ Notification service initialized');

    // Initialize database with proper error handling
    final databaseService = DatabaseService();
    await databaseService.database; // Triggers database initialization
    debugPrint('✅ Database initialized successfully');

    // Pre-warm SharedPreferences for faster access
    await SharedPreferences.getInstance();
    debugPrint('✅ SharedPreferences initialized');
  } catch (e, stackTrace) {
    debugPrint('❌ Critical error during service initialization: $e');
    debugPrint('Stack trace: $stackTrace');

    // Could show a critical error dialog here if needed
    // For now, we'll let the app continue and handle errors in AppInitializer
  }

  // Run the app with error boundary
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Order matters - AuthProvider should be first as others depend on it
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          lazy: false, // Initialize immediately
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          lazy: false, // Initialize immediately for theme
        ),
        ChangeNotifierProxyProvider<AuthProvider, HabitProvider>(
          create: (_) => HabitProvider(),
          update:
              (_, authProvider, previousHabitProvider) =>
                  previousHabitProvider ?? HabitProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SettingsProvider>(
          create: (_) => SettingsProvider(),
          update:
              (_, authProvider, previousSettingsProvider) =>
                  previousSettingsProvider ?? SettingsProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'HabitFlow',

            // Enhanced theme configuration
            theme: themeProvider.getLightTheme(),
            darkTheme: themeProvider.getDarkTheme(),
            themeMode: themeProvider.themeMode,

            // Performance optimizations
            debugShowCheckedModeBanner: false,

            // Better route management
            onGenerateRoute: (settings) {
              // Handle deep linking or custom routing here if needed
              return null; // Let the default routing handle it
            },

            // Error handling for the entire app
            builder: (context, widget) {
              // Global error boundary
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return _buildErrorWidget(context, errorDetails);
              };

              return widget ?? const SizedBox.shrink();
            },

            home: const AppInitializer(),
          );
        },
      ),
    );
  }

  // Custom error widget for better error display
  Widget _buildErrorWidget(
    BuildContext context,
    FlutterErrorDetails errorDetails,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.errorContainer,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The app encountered an unexpected error',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  SystemNavigator.pop();
                },
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
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

