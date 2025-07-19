import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../onboarding_screen.dart';

class OnboardingPage extends StatefulWidget {
  final OnboardingPageData data;
  final bool isActive;

  const OnboardingPage({Key? key, required this.data, required this.isActive})
    : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _floatingAnimation;

  final List<AnimationController> _iconControllers = [];
  final List<Animation<double>> _iconAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeIconAnimations();

    if (widget.isActive) {
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    // Main content animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animation curves
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  void _initializeIconAnimations() {
    _iconControllers.clear();
    _iconAnimations.clear();

    for (int i = 0; i < widget.data.animations.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 800 + (i * 200)),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));

      _iconControllers.add(controller);
      _iconAnimations.add(animation);
    }
  }

  void _startAnimations() {
    // Start main animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _rotationController.forward();
    _floatingController.repeat(reverse: true);

    // Start icon animations with delays
    for (int i = 0; i < _iconControllers.length; i++) {
      Future.delayed(
        Duration(
          milliseconds: (widget.data.animations[i].delay * 1000).round(),
        ),
        () {
          if (mounted) {
            _iconControllers[i].forward();
          }
        },
      );
    }
  }

  void _resetAnimations() {
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();
    _rotationController.reset();
    _floatingController.reset();

    for (final controller in _iconControllers) {
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _startAnimations();
    } else if (!widget.isActive && oldWidget.isActive) {
      _resetAnimations();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _floatingController.dispose();

    for (final controller in _iconControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated illustration area
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: screenSize.width * 0.6,
                        height: screenSize.width * 0.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Main icon with floating animation
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _scaleAnimation,
                    _rotationAnimation,
                    _floatingAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 2 * math.pi * 0.1,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.data.iconData,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Floating animated icons
                ...List.generate(
                  widget.data.animations.length,
                  (index) => _buildFloatingIcon(
                    widget.data.animations[index],
                    _iconAnimations[index],
                    screenSize,
                  ),
                ),

                // Particle effects
                ...List.generate(
                  8,
                  (index) => _buildParticle(index, screenSize),
                ),
              ],
            ),
          ),

          // Text content
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      widget.data.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      widget.data.subtitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Description
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      widget.data.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(
    AnimationData animationData,
    Animation<double> animation,
    Size screenSize,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          left: animationData.position.dx * screenSize.width,
          top: animationData.position.dy * screenSize.height * 0.6,
          child: Transform.scale(
            scale: animation.value,
            child: Transform.rotate(
              angle: animation.value * 2 * math.pi,
              child: Container(
                width: animationData.size + 16,
                height: animationData.size + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  animationData.icon,
                  size: animationData.size,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticle(int index, Size screenSize) {
    final random = math.Random(index);
    final size = 4.0 + random.nextDouble() * 8.0;
    final left = random.nextDouble() * screenSize.width;
    final animationDelay = random.nextDouble() * 2.0;

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Positioned(
          left: left,
          top:
              screenSize.height * 0.3 +
              math.sin(_floatingAnimation.value * 0.02 + index) * 20,
          child: Transform.scale(
            scale:
                0.5 + math.sin(_floatingAnimation.value * 0.01 + index) * 0.5,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for additional visual effects
class OnboardingBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  OnboardingBackgroundPainter({
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Draw animated background shapes
    for (int i = 0; i < 5; i++) {
      final random = math.Random(i);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 20 + random.nextDouble() * 40;

      canvas.drawCircle(
        Offset(
          x + math.sin(animationValue * 0.5 + i) * 10,
          y + math.cos(animationValue * 0.3 + i) * 15,
        ),
        radius * (0.5 + math.sin(animationValue + i) * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Extension for additional utility methods
extension OnboardingPageExtensions on OnboardingPage {
  static List<BoxShadow> get defaultShadows => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
  ];
}
