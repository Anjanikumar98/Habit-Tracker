import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/screens/authentication_screen/signup_screen.dart';
import 'package:habit_tracker/utlis/validators.dart';
import 'package:habit_tracker/widgets/custom_button.dart';
import 'package:habit_tracker/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/auth_provider.dart';
import 'package:habit_tracker/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isKeyboardVisible = false;

  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formOpacityAnimation;

  // Biometric authentication
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedCredentials();
    _checkBiometricAvailability();

    // Listen to keyboard visibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(context);
      setState(() {
        _isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;
      });
    });
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _formOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeIn),
    );

    // Start animations
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _formAnimationController.forward();
    });
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('remember_me') ?? false) {
      setState(() {
        _emailController.text = prefs.getString('saved_email') ?? '';
        _rememberMe = true;
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    // In a real app, you would use local_auth package
    // For now, we'll simulate this
    setState(() {
      _isBiometricAvailable = true; // Simulated
      _isBiometricEnabled = false; // User preference
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      // Haptic feedback for validation error
      HapticFeedback.lightImpact();
      return;
    }

    // Haptic feedback for successful validation
    HapticFeedback.selectionClick();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final result = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result.success) {
          // Save credentials if remember me is checked
          if (_rememberMe) {
            await _saveCredentials();
          } else {
            await _clearSavedCredentials();
          }

          // Success haptic feedback
      //    HapticFeedback.notificationSuccess();

          // Show success message briefly
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Welcome back, ${result.user?.name ?? 'User'}!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Navigate after a short delay to show success message
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const HomeScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          }
        } else {
          // Error haptic feedback
        //  HapticFeedback.notificationError();

          _showErrorSnackBar(result.message);
        }
      }
    } catch (e) {
      if (mounted) {
   //     HapticFeedback.notificationError();
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', true);
    await prefs.setString('saved_email', _emailController.text.trim());
  }

  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remember_me');
    await prefs.remove('saved_email');
  }

  Future<void> _authenticateWithBiometric() async {
    // In a real app, implement biometric authentication
    HapticFeedback.lightImpact();

    // Simulate biometric authentication
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.fingerprint, color: Colors.blue),
                SizedBox(width: 8),
                Text('Biometric Authentication'),
              ],
            ),
            content: const Text(
              'Place your finger on the sensor or look at the camera.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Simulate successful authentication
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text('Simulate Success'),
              ),
            ],
          ),
    );
  }

  void _navigateToSignUp() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const SignUpScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToForgotPassword() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const ForgotPasswordScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height - MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dynamic spacing based on keyboard visibility
                    SizedBox(height: _isKeyboardVisible ? 40 : 80),

                    // Animated App Logo and Title
                    AnimatedBuilder(
                      animation: _logoScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Column(
                            children: [
                              Hero(
                                tag: 'app_logo',
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        colorScheme.primary,
                                        colorScheme.secondary,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 25,
                                        offset: const Offset(0, 10),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.psychology,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Welcome Back',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to continue your habit journey',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // Animated Form
                    SlideTransition(
                      position: _formSlideAnimation,
                      child: FadeTransition(
                        opacity: _formOpacityAnimation,
                        child: Column(
                          children: [
                            // Email Field with improved styling
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'Enter your email address',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              validator: Validators.email,
                              textInputAction: TextInputAction.next,
                            ),

                            const SizedBox(height: 16),

                            // Password Field with strength indicator
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              isPassword: true,
                              isPasswordVisible: _isPasswordVisible,
                              prefixIcon: Icons.lock_outlined,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: Validators.password,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _signIn(),
                            ),

                            const SizedBox(height: 20),

                            // Enhanced Remember Me and Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          _rememberMe = !_rememberMe;
                                        });
                                      },
                                      child: Text(
                                        'Remember me',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: _navigateToForgotPassword,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Enhanced Sign In Button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return CustomButton(
                                  text: 'Sign In',
                                  onPressed:
                                      authProvider.isLoading ? null : _signIn,
                                  isLoading: authProvider.isLoading,
                                );
                              },
                            ),

                            // Biometric Authentication Option
                            if (_isBiometricAvailable) ...[
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _authenticateWithBiometric,
                                icon: const Icon(Icons.fingerprint),
                                label: const Text('Use Biometric'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  side: BorderSide(color: colorScheme.primary),
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Enhanced Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          colorScheme.onSurface.withOpacity(
                                            0.2,
                                          ),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.5,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          colorScheme.onSurface.withOpacity(
                                            0.2,
                                          ),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Enhanced Sign Up Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _navigateToSignUp,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: colorScheme.primary.withOpacity(
                                        0.1,
                                      ),
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
