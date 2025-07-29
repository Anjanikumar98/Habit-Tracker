import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.85),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon/Logo
                Container(
                  width: size.width * 0.3,
                  height: size.width * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surface.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: size.width * 0.15,
                    color: colorScheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 30),

                // App Title
                Text(
                  'HabitFlow',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.3,
                    color: colorScheme.onPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  'Building Better Habits',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onPrimary.withOpacity(0.8),
                    fontWeight: FontWeight.w300,
                  ),
                ),

                const SizedBox(height: 40),
                // Loading Indicator
                const CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
