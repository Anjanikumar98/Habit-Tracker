import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _rippleController;
  late AnimationController _textSlideController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _textSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textSlideController, curve: Curves.easeOutCubic),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Start animations sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Start fade in
    _fadeController.forward();

    // Wait a bit, then start scale and ripple
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    _rippleController.repeat();

    // Start rotation
    await Future.delayed(const Duration(milliseconds: 300));
    _rotationController.repeat();

    // Start text slide
    await Future.delayed(const Duration(milliseconds: 600));
    _textSlideController.forward();

    // Start progress animation
    await Future.delayed(const Duration(milliseconds: 800));
    _progressController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _rippleController.dispose();
    _textSlideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDark
                    ? [
                      colorScheme.surface,
                      colorScheme.surface.withBlue(50),
                      colorScheme.primary.withOpacity(0.1),
                    ]
                    : [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.9),
                      colorScheme.secondary.withOpacity(0.8),
                    ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(8, (index) => _buildFloatingParticle(index, size)),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo with ripple effect
                    _buildAnimatedLogo(colorScheme, size, isDark),

                    const SizedBox(height: 40),

                    // Animated title and subtitle
                    _buildAnimatedText(colorScheme, isDark),

                    const SizedBox(height: 60),

                    // Enhanced progress indicator
                    _buildProgressIndicator(colorScheme, isDark),

                    const SizedBox(height: 20),

                    // Loading text
                    _buildLoadingText(colorScheme, isDark),
                  ],
                ),
              ),
            ),

            // Version info at bottom
            _buildVersionInfo(colorScheme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index, Size size) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        final angle =
            (index * math.pi * 2 / 8) + (_rippleController.value * 2 * math.pi);
        final radius =
            50 + (math.sin(_rippleController.value * 2 * math.pi) * 20);

        return Positioned(
          left: size.width / 2 + math.cos(angle) * radius - 4,
          top: size.height / 2 + math.sin(angle) * radius - 4,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(
                0.3 * (1 - _rippleController.value),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo(ColorScheme colorScheme, Size size, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ripple effects
        AnimatedBuilder(
          animation: _rippleAnimation,
          builder: (context, child) {
            return Container(
              width: size.width * 0.35 * (1 + _rippleAnimation.value * 0.5),
              height: size.width * 0.35 * (1 + _rippleAnimation.value * 0.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (isDark ? Colors.white : colorScheme.onPrimary)
                      .withOpacity(0.3 * (1 - _rippleAnimation.value)),
                  width: 2,
                ),
              ),
            );
          },
        ),

        // Second ripple
        AnimatedBuilder(
          animation: _rippleAnimation,
          builder: (context, child) {
            final delay = (_rippleAnimation.value - 0.3).clamp(0.0, 1.0);
            return Container(
              width: size.width * 0.35 * (1 + delay * 0.8),
              height: size.width * 0.35 * (1 + delay * 0.8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (isDark ? Colors.white : colorScheme.onPrimary)
                      .withOpacity(0.2 * (1 - delay)),
                  width: 1,
                ),
              ),
            );
          },
        ),

        // Main logo container
        ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * math.pi,
                child: Container(
                  width: size.width * 0.32,
                  height: size.width * 0.32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isDark ? colorScheme.primary : colorScheme.surface)
                            .withOpacity(0.9),
                        (isDark
                                ? colorScheme.primaryContainer
                                : colorScheme.surface)
                            .withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.5 : 0.25),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: (isDark ? colorScheme.primary : Colors.white)
                            .withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: -2,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.self_improvement,
                    size: size.width * 0.16,
                    color:
                        isDark
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedText(ColorScheme colorScheme, bool isDark) {
    return SlideTransition(
      position: _textSlideAnimation,
      child: Column(
        children: [
          // App Title with typing effect
          AnimatedBuilder(
            animation: _textSlideController,
            builder: (context, child) {
              const title = 'HabitFlow';
              final visibleLength =
                  (_textSlideController.value * title.length).round();
              final visibleText = title.substring(0, visibleLength);

              return Text(
                visibleText,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Animated subtitle
          FadeTransition(
            opacity: _textSlideController,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (isDark ? Colors.white : colorScheme.onPrimary)
                    .withOpacity(0.1),
                border: Border.all(
                  color: (isDark ? Colors.white : colorScheme.onPrimary)
                      .withOpacity(0.2),
                ),
              ),
              child: Text(
                'Building Better Habits, One Day at a Time',
                style: TextStyle(
                  fontSize: 16,
                  color: (isDark
                          ? colorScheme.onSurface
                          : colorScheme.onPrimary)
                      .withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme, bool isDark) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          // Custom progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: (isDark ? Colors.white : colorScheme.onPrimary)
                  .withOpacity(0.2),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          isDark ? colorScheme.primary : colorScheme.onPrimary,
                          isDark
                              ? colorScheme.primaryContainer
                              : colorScheme.surface,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark
                                  ? colorScheme.primary
                                  : colorScheme.onPrimary)
                              .withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Progress percentage
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: (isDark
                          ? colorScheme.onSurface
                          : colorScheme.onPrimary)
                      .withOpacity(0.8),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingText(ColorScheme colorScheme, bool isDark) {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final loadingStates = [
          'Initializing...',
          'Loading habits...',
          'Setting up workspace...',
          'Almost ready...',
        ];

        final currentIndex = (_progressAnimation.value *
                (loadingStates.length - 1))
            .round()
            .clamp(0, loadingStates.length - 1);

        return Text(
          loadingStates[currentIndex],
          style: TextStyle(
            fontSize: 14,
            color: (isDark ? colorScheme.onSurface : colorScheme.onPrimary)
                .withOpacity(0.7),
            fontWeight: FontWeight.w300,
          ),
        );
      },
    );
  }

  Widget _buildVersionInfo(ColorScheme colorScheme, bool isDark) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          'Version 1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: (isDark ? colorScheme.onSurface : colorScheme.onPrimary)
                .withOpacity(0.5),
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
