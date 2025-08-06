import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/models/users.dart';
import 'package:habit_tracker/services/auth_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null && _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail ?? _currentUser?.email;
  String? get userName => _userName ?? _currentUser?.name;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.initialize();
      _currentUser = _authService.currentUser;

      // Sync authentication state
      if (_currentUser != null) {
        _isAuthenticated = true;
        _userEmail = _currentUser!.email;
        _userName = _currentUser!.name;
        await _saveAuthState();
      } else {
        // Check if we have stored auth state
        await checkAuthStatus();
      }

      _isInitialized = true;
    } catch (e) {
      print('Error initializing auth provider: $e');
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validate input
      if (name.trim().isEmpty) {
        return AuthResult(success: false, message: 'Name is required');
      }

      if (!_isValidEmail(email)) {
        return AuthResult(
          success: false,
          message: 'Please enter a valid email address',
        );
      }

      final result = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        _currentUser = result.user;
        _isAuthenticated = true;
        _userEmail = result.user!.email;
        _userName = result.user!.name;

        // Save authentication state
        await _saveAuthState();
        await _trackEvent('user_signup', {'method': 'email', 'success': true});
      }

      return result;
    } catch (e) {
      await _trackEvent('user_signup', {
        'method': 'email',
        'success': false,
        'error': e.toString(),
      });
      return AuthResult(
        success: false,
        message: 'An error occurred during sign up: ${e.toString()}',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', _isAuthenticated);
      if (_userEmail != null) await prefs.setString('userEmail', _userEmail!);
      if (_userName != null) await prefs.setString('userName', _userName!);

      // Also save individual user data for backward compatibility
      if (_currentUser != null) {
        await prefs.setString('user_id', _currentUser!.id);
        await prefs.setString('user_name', _currentUser!.name);
        await prefs.setString('user_email', _currentUser!.email);
      }
    } catch (e) {
      print('Error saving auth state: $e');
    }
  }

  // Check if user is already authenticated (from SharedPreferences)
  Future<bool> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _userEmail = prefs.getString('userEmail');
      _userName = prefs.getString('userName');

      // If we have auth state but no current user, try to restore user
      if (_isAuthenticated && _currentUser == null && _userEmail != null) {
        try {
          // Try to get user from auth service
          final userData = await _authService.getUserByEmail(_userEmail!);
          if (userData != null) {
            _currentUser = userData;
          } else {
            // Clear invalid auth state
            _isAuthenticated = false;
            await _clearAuthState();
          }
        } catch (e) {
          print('Error restoring user: $e');
          _isAuthenticated = false;
          await _clearAuthState();
        }
      }

      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      print('Error checking auth status: $e');
      _isAuthenticated = false;
      return false;
    }
  }

  Future<void> _clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isAuthenticated');
      await prefs.remove('userEmail');
      await prefs.remove('userName');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
    } catch (e) {
      print('Error clearing auth state: $e');
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validate input
      if (email.trim().isEmpty || password.isEmpty) {
        return AuthResult(success: false, message: 'Please fill in all fields');
      }

      if (!_isValidEmail(email)) {
        return AuthResult(
          success: false,
          message: 'Please enter a valid email address',
        );
      }

      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (result.success && result.user != null) {
        _currentUser = result.user;
        _isAuthenticated = true;
        _userEmail = result.user!.email;
        _userName = result.user!.name;

        // Save authentication state
        await _saveAuthState();
        await _trackEvent('user_signin', {'method': 'email', 'success': true});
      } else {
        await _trackEvent('user_signin', {
          'method': 'email',
          'success': false,
          'error': result.message,
        });
      }

      return result;
    } catch (e) {
      await _trackEvent('user_signin', {
        'method': 'email',
        'success': false,
        'error': e.toString(),
      });
      return AuthResult(
        success: false,
        message: 'An error occurred during sign in: ${e.toString()}',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _trackEvent('user_signout', {'method': 'manual'});
      await _authService.signOut();

      _currentUser = null;
      _isAuthenticated = false;
      _userEmail = null;
      _userName = null;

      await _clearAuthState();
    } catch (e) {
      print('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? profilePicture,
    Map<String, dynamic>? preferences,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.updateUserProfile(
        name: name,
        profilePicture: profilePicture,
        preferences: preferences,
      );

      if (success) {
        _currentUser = _authService.currentUser;
        if (_currentUser != null) {
          _userName = _currentUser!.name;
          await _saveAuthState();
        }

        await _trackEvent('profile_update', {
          'success': true,
          'updated_fields': [
            if (name != null) 'name',
            if (profilePicture != null) 'profilePicture',
            if (preferences != null) 'preferences',
          ],
        });
      }

      return success;
    } catch (e) {
      print('Error updating profile: $e');
      await _trackEvent('profile_update', {
        'success': false,
        'error': e.toString(),
      });
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Validate new password
      if (newPassword.length < 6) {
        return false;
      }

      final success = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      await _trackEvent('password_change', {'success': success});

      return success;
    } catch (e) {
      print('Error changing password: $e');
      await _trackEvent('password_change', {
        'success': false,
        'error': e.toString(),
      });
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitFeedback({
    required String title,
    required String content,
    required FeedbackType type,
    required int rating,
  }) async {
    try {
      final success = await _authService.submitFeedback(
        title: title,
        content: content,
        type: type,
        rating: rating,
      );

      await _trackEvent('feedback_submitted', {
        'type': type.toString().split('.').last,
        'rating': rating,
        'success': success,
      });

      return success;
    } catch (e) {
      print('Error submitting feedback: $e');
      await _trackEvent('feedback_submitted', {
        'success': false,
        'error': e.toString(),
      });
      return false;
    }
  }

  Future<List<UserFeedback>> getUserFeedback() async {
    try {
      return await _authService.getUserFeedback();
    } catch (e) {
      print('Error getting user feedback: $e');
      return [];
    }
  }

  // Analytics and feedback methods
  Future<void> trackEvent(String event, Map<String, dynamic> parameters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('analytics_events') ?? '[]';
      final events = List<Map<String, dynamic>>.from(jsonDecode(eventsJson));

      events.add({
        'event': event,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
        'userId': _currentUser?.id,
        'userEmail': _userEmail,
      });

      // Keep only last 100 events
      if (events.length > 100) {
        events.removeRange(0, events.length - 100);
      }

      await prefs.setString('analytics_events', jsonEncode(events));
    } catch (e) {
      debugPrint('Error tracking event: $e');
    }
  }

  // Internal method for tracking events
  Future<void> _trackEvent(
    String event,
    Map<String, dynamic> parameters,
  ) async {
    await trackEvent(event, parameters);
  }

  Future<AuthResult> resetPassword({required String email}) async {
    _setLoading(true);

    try {
      if (!_isValidEmail(email)) {
        return AuthResult(
          success: false,
          message: 'Please enter a valid email address',
        );
      }

      await Future.delayed(const Duration(seconds: 1));

      final userData = await _getUserFromDatabase(email.toLowerCase());
      if (userData == null) {
        return AuthResult(
          success: false,
          message: 'No account found with this email address',
        );
      }

      await _trackEvent('password_reset_requested', {
        'email': email,
        'success': true,
      });

      // In a real app, you would send an email with reset link
      return AuthResult(
        success: true,
        message: 'Password reset instructions have been sent to your email',
      );
    } catch (e) {
      await _trackEvent('password_reset_requested', {
        'email': email,
        'success': false,
        'error': e.toString(),
      });
      return AuthResult(
        success: false,
        message: 'Failed to send reset email. Please try again.',
      );
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  String getUserInitials() {
    final name = _userName ?? _currentUser?.name ?? '';
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name.length >= 2
          ? name.substring(0, 2).toUpperCase()
          : name.toUpperCase();
    }
  }

  String getGreeting() {
    final name = _userName ?? _currentUser?.name ?? '';
    if (name.isEmpty) return 'Welcome';

    final hour = DateTime.now().hour;
    final firstName = name.split(' ')[0];

    if (hour < 12) {
      return 'Good morning, $firstName!';
    } else if (hour < 17) {
      return 'Good afternoon, $firstName!';
    } else {
      return 'Good evening, $firstName!';
    }
  }

  int getDaysActive() {
    if (_currentUser == null) return 0;

    final now = DateTime.now();
    final createdAt = _currentUser!.createdAt;
    return now.difference(createdAt).inDays;
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email.trim());
  }

  final String _usersKey = 'users_data';

  Future<Map<String, dynamic>?> _getUserFromDatabase(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersData = prefs.getStringList(_usersKey) ?? [];

      for (final userData in usersData) {
        final user = jsonDecode(userData);
        if (user['user']['email'] == email) {
          return user;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user from database: $e');
      return null;
    }
  }
}
