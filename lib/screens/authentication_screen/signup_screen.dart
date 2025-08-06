import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/utlis/validators.dart';
import 'package:habit_tracker/widgets/custom_button.dart';
import 'package:habit_tracker/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/auth_provider.dart';
import 'package:habit_tracker/screens/home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _agreeToMarketing = false;

  // Password strength tracking
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;
  List<String> _passwordRequirements = [];

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animations
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideAnimationController.forward();
    });
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      _passwordStrength = _calculatePasswordStrength(password);
      _passwordStrengthText = _getPasswordStrengthText(_passwordStrength);
      _passwordStrengthColor = _getPasswordStrengthColor(_passwordStrength);
      _passwordRequirements = _getPasswordRequirements(password);
    });
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;

    double strength = 0.0;

    // Length check
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.1;

    return strength.clamp(0.0, 1.0);
  }

  String _getPasswordStrengthText(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.6) return 'Fair';
    if (strength < 0.8) return 'Good';
    return 'Strong';
  }

  Color _getPasswordStrengthColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    if (strength < 0.8) return Colors.blue;
    return Colors.green;
  }

  List<String> _getPasswordRequirements(String password) {
    List<String> requirements = [];

    if (password.length < 8) {
      requirements.add('At least 8 characters');
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      requirements.add('One lowercase letter');
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      requirements.add('One uppercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      requirements.add('One number');
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      requirements.add('One special character');
    }

    return requirements;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    if (!_agreeToTerms) {
      HapticFeedback.heavyImpact();
      _showErrorDialog(
        'Terms Required',
        'Please agree to the Terms and Conditions to continue.',
      );
      return;
    }

    if (_passwordStrength < 0.5) {
      HapticFeedback.heavyImpact();
      _showErrorDialog(
        'Weak Password',
        'Please choose a stronger password for better security.',
      );
      return;
    }

    HapticFeedback.selectionClick();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final result = await authProvider.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        //    agreeToMarketing: _agreeToMarketing,
      );

      if (mounted) {
        if (result.success) {
          HapticFeedback.mediumImpact();

          // Show success dialog instead of snackbar
          await _showSuccessDialog();

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
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        } else {
          HapticFeedback.heavyImpact();
          _showErrorDialog('Sign Up Failed', result.message);
        }
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        _showErrorDialog(
          'Error',
          'An unexpected error occurred. Please try again.',
        );
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Welcome Aboard!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your account has been created successfully.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Get ready to build amazing habits!',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(title),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _showTermsDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Terms and Conditions'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: SingleChildScrollView(
                child: Text(
                  '''By using our Habit Tracker app, you agree to the following terms:

1. Account Responsibility
You are responsible for maintaining the confidentiality of your account and password.

2. Data Usage
We collect and use your data to provide personalized habit tracking experiences.

3. Privacy
Your personal information is protected according to our Privacy Policy.

4. Prohibited Use
You may not use the app for any illegal or unauthorized purpose.

5. Modifications
We reserve the right to modify these terms at any time.

6. Termination
We may terminate your account if you violate these terms.

For complete terms, visit our website.''',
                  style: textTheme.bodySmall,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: SingleChildScrollView(
                child: Text(
                  '''Our Privacy Policy explains how we collect, use, and protect your information:

1. Information We Collect
- Account information (name, email)
- Habit tracking data
- App usage analytics

2. How We Use Information
- Provide personalized experiences
- Improve our services
- Send important updates

3. Information Sharing
We do not sell your personal information to third parties.

4. Data Security
We use industry-standard security measures to protect your data.

5. Your Rights
You can access, update, or delete your personal information.

6. Contact Us
For privacy questions, contact us through the app.

For complete policy, visit our website.''',
                  style: textTheme.bodySmall,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      size.height - MediaQuery.of(context).padding.top - 56,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Enhanced Header
                        Column(
                          children: [
                            Hero(
                              tag: 'signup_header',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  'Create Account',
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start your habit-building journey today',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        const SizedBox(height: 31),

                        // Form Fields
                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          keyboardType: TextInputType.name,
                          prefixIcon: Icons.person_outlined,
                          validator: Validators.name,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

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

                        // Password Field with Strength Indicator
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Create a strong password',
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
                              textInputAction: TextInputAction.next,
                            ),

                            // Password Strength Indicator
                            if (_passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: _passwordStrength,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _passwordStrengthColor,
                                      ),
                                      minHeight: 4,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _passwordStrengthText,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: _passwordStrengthColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          isPassword: true,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          prefixIcon: Icons.lock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          validator: _validateConfirmPassword,
                          textInputAction: TextInputAction.done,
                        ),

                        const SizedBox(height: 20),

                        // Enhanced Password Requirements
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                _passwordStrength > 0.7
                                    ? Colors.green.withOpacity(0.1)
                                    : colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _passwordStrength > 0.7
                                      ? Colors.green.withOpacity(0.3)
                                      : colorScheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _passwordStrength > 0.7
                                        ? Icons.check_circle_outline
                                        : Icons.info_outlined,
                                    size: 16,
                                    color:
                                        _passwordStrength > 0.7
                                            ? Colors.green
                                            : colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _passwordStrength > 0.7
                                        ? 'Strong Password ✓'
                                        : 'Password Requirements',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          _passwordStrength > 0.7
                                              ? Colors.green
                                              : colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              if (_passwordRequirements.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ..._passwordRequirements.map(
                                  (requirement) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 6,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          requirement,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              if (_passwordStrength > 0.7) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Your password meets all security requirements',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Enhanced Terms and Conditions
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (value) {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _agreeToTerms = value ?? false;
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _agreeToTerms = !_agreeToTerms;
                                      });
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        style: textTheme.bodySmall,
                                        children: [
                                          const TextSpan(
                                            text: 'I agree to the ',
                                          ),
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: _showTermsDialog,
                                              child: Text(
                                                'Terms and Conditions',
                                                style: TextStyle(
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const TextSpan(text: ' and '),
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: _showPrivacyDialog,
                                              child: Text(
                                                'Privacy Policy',
                                                style: TextStyle(
                                                  color: colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Marketing emails checkbox
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _agreeToMarketing,
                                    onChanged: (value) {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _agreeToMarketing = value ?? false;
                                      });
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _agreeToMarketing = !_agreeToMarketing;
                                      });
                                    },
                                    child: Text(
                                      'I would like to receive tips and updates about habit building (optional)',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 31),

                        // Enhanced Create Account Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return CustomButton(
                              text: 'Create Account',
                              onPressed:
                                  authProvider.isLoading ? null : _signUp,
                              isLoading: authProvider.isLoading,
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Enhanced Sign In Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: colorScheme.primary.withOpacity(0.1),
                                ),
                                child: Text(
                                  'Sign In',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
