import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  static const int _totalPages = 4;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Welcome to HabitFlow',
      subtitle: 'Your personal habit tracker',
      description:
          'Build positive habits, track your progress, and achieve your goals with our intuitive habit tracking system.',
      imagePath: 'assets/images/onboarding_1.png',
      backgroundColor: const Color(0xFF6C5CE7),
      iconData: Icons.rocket_launch,
      animations: [
        AnimationData(
          icon: Icons.star,
          delay: 0.2,
          size: 24,
          position: const Offset(0.2, 0.3),
        ),
        AnimationData(
          icon: Icons.favorite,
          delay: 0.4,
          size: 20,
          position: const Offset(0.8, 0.25),
        ),
        AnimationData(
          icon: Icons.celebration,
          delay: 0.6,
          size: 22,
          position: const Offset(0.7, 0.7),
        ),
      ],
    ),
    OnboardingPageData(
      title: 'Track Your Habits',
      subtitle: 'Simple and effective',
      description:
          'Easily add habits, set reminders, and track your daily progress with our clean and intuitive interface.',
      imagePath: 'assets/images/onboarding_2.png',
      backgroundColor: const Color(0xFF00B894),
      iconData: Icons.track_changes,
      animations: [
        AnimationData(
          icon: Icons.check_circle,
          delay: 0.3,
          size: 26,
          position: const Offset(0.15, 0.2),
        ),
        AnimationData(
          icon: Icons.timeline,
          delay: 0.5,
          size: 24,
          position: const Offset(0.85, 0.3),
        ),
        AnimationData(
          icon: Icons.trending_up,
          delay: 0.7,
          size: 22,
          position: const Offset(0.1, 0.75),
        ),
      ],
    ),
    OnboardingPageData(
      title: 'Build Streaks',
      subtitle: 'Stay motivated',
      description:
          'Maintain your habit streaks, celebrate milestones, and get insights into your progress patterns.',
      imagePath: 'assets/images/onboarding_3.png',
      backgroundColor: const Color(0xFFE17055),
      iconData: Icons.local_fire_department,
      animations: [
        AnimationData(
          icon: Icons.local_fire_department,
          delay: 0.2,
          size: 28,
          position: const Offset(0.2, 0.25),
        ),
        AnimationData(
          icon: Icons.emoji_events,
          delay: 0.4,
          size: 24,
          position: const Offset(0.8, 0.35),
        ),
        AnimationData(
          icon: Icons.insights,
          delay: 0.6,
          size: 22,
          position: const Offset(0.75, 0.65),
        ),
      ],
    ),
    OnboardingPageData(
      title: 'Get Started',
      subtitle: 'Begin your journey',
      description:
          'Ready to transform your life? Let\'s start building better habits together and achieve your goals!',
      imagePath: 'assets/images/onboarding_4.png',
      backgroundColor: const Color(0xFF0984E3),
      iconData: Icons.flag,
      animations: [
        AnimationData(
          icon: Icons.psychology,
          delay: 0.2,
          size: 24,
          position: const Offset(0.25, 0.3),
        ),
        AnimationData(
          icon: Icons.self_improvement,
          delay: 0.4,
          size: 26,
          position: const Offset(0.75, 0.25),
        ),
        AnimationData(
          icon: Icons.energy_savings_leaf,
          delay: 0.6,
          size: 22,
          position: const Offset(0.8, 0.7),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    try {
      // Save that onboarding is completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);

      // Add haptic feedback
      HapticFeedback.lightImpact();

      // Navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return SlideTransition(
                position: animation.drive(
                  Tween(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      // If there's an error saving preferences, still navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _pages[_currentPage].backgroundColor.withOpacity(0.8),
                  _pages[_currentPage].backgroundColor,
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with skip button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo or app name
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'HabitFlow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Skip button
                      if (_currentPage < _totalPages - 1)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: TextButton(
                            onPressed: _skipOnboarding,
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      HapticFeedback.selectionClick();
                    },
                    itemCount: _totalPages,
                    itemBuilder: (context, index) {
                      return OnboardingPage(
                        data: _pages[index],
                        isActive: index == _currentPage,
                      );
                    },
                  ),
                ),

                // Bottom navigation
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Page indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_totalPages, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 8.0,
                            width: index == _currentPage ? 32.0 : 8.0,
                            decoration: BoxDecoration(
                              color:
                                  index == _currentPage
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 32),

                      // Navigation buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous button
                          if (_currentPage > 0)
                            AnimatedOpacity(
                              opacity: _currentPage > 0 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: TextButton.icon(
                                onPressed:
                                    _currentPage > 0 ? _previousPage : null,
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Previous',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(width: 100),

                          // Next/Get Started button
                          ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  _pages[_currentPage].backgroundColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage == _totalPages - 1
                                      ? 'Get Started'
                                      : 'Next',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPage == _totalPages - 1
                                      ? Icons.rocket_launch
                                      : Icons.arrow_forward_ios,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data classes for onboarding pages
class OnboardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final Color backgroundColor;
  final IconData iconData;
  final List<AnimationData> animations;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
    required this.iconData,
    required this.animations,
  });
}

class AnimationData {
  final IconData icon;
  final double delay;
  final double size;
  final Offset position;

  AnimationData({
    required this.icon,
    required this.delay,
    required this.size,
    required this.position,
  });
}
