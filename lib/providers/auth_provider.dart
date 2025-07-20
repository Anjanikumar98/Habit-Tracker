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
  bool get isLoggedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.initialize();
      _currentUser = _authService.currentUser;
      _isInitialized = true;
    } catch (e) {
      print('Error initializing auth provider: $e');
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
      final result = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );

      if (result.success) {
        _currentUser = result.user;
      }

      return result;
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An error occurred during sign up',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user is already authenticated (from SharedPreferences)
  Future<bool> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _userEmail = prefs.getString('userEmail');
      _userName = prefs.getString('userName');
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (result.success) {
        _currentUser = result.user;
      }

      return result;
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An error occurred during sign in',
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
      await _authService.signOut();
      _currentUser = null;
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
      }

      return success;
    } catch (e) {
      print('Error updating profile: $e');
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
      final success = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return success;
    } catch (e) {
      print('Error changing password: $e');
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
      return await _authService.submitFeedback(
        title: title,
        content: content,
        type: type,
        rating: rating,
      );
    } catch (e) {
      print('Error submitting feedback: $e');
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

  String _hashPassword(String password) {
    // Simple hash for demo - in production use proper hashing like bcrypt
    return password.codeUnits.map((e) => e * 7 % 256).join();
  }

  String _generateUserId() {
    final random = Random();
    return '${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(10000)}';
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

  Future<AuthResult> resetPassword({required String email}) async {
    _setLoading(true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final userData = await _getUserFromDatabase(email.toLowerCase());
      if (userData == null) {
        return AuthResult(
          success: false,
          message: 'No account found with this email address',
        );
      }

      // In a real app, you would send an email with reset link
      return AuthResult(
        success: true,
        message: 'Password reset instructions have been sent to your email',
      );
    } catch (e) {
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
    if (_currentUser == null) return '';

    final nameParts = _currentUser!.name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return nameParts[0].substring(0, 2).toUpperCase();
    }
  }

  String getGreeting() {
    if (_currentUser == null) return 'Welcome';

    final hour = DateTime.now().hour;
    final firstName = _currentUser!.name.split(' ')[0];

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

  String _usersKey = 'users_data';

  Future<Map<String, dynamic>?> _getUserFromDatabase(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = Map<String, dynamic>.from(jsonDecode(usersJson));
    return users[email];
  }
}

