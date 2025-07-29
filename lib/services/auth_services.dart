import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/models/users.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class AuthService {
  static const String _usersKey = 'users_data';
  static const String _currentUserKey = 'current_user';
  static const String _feedbackKey = 'user_feedback';
  static const String _sessionsKey = 'user_sessions';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Backend URL - change this to your actual backend URL
  final String baseUrl = 'http://localhost:3000/api';

  // Initialize service
  Future<void> initialize() async {
    await _loadCurrentUser();
  }

  // Authentication Methods with Backend Integration
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'deviceInfo': {
            'platform': Platform.operatingSystem,
            'version': Platform.version,
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body)['user'];
        return AuthResult(
          success: true,
          user: User.fromJson(data),
          message: '',
        );
      } else {
        final jsonBody = jsonDecode(response.body);
        return AuthResult(
          success: false,
          message: jsonBody['error'] ?? 'Signup failed',
        );
      }
    } catch (e) {
      return AuthResult(success: false, message: 'Network or server error');
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(success: false, message: 'Please fill in all fields');
      }

      // Try backend first
      try {
        final backendResponse = await http.post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email.trim().toLowerCase(),
            'password': password,
          }),
        );

        if (backendResponse.statusCode == 200) {
          final responseData = jsonDecode(backendResponse.body);

          // Create user from backend response
          final user = User(
            id: responseData['user']['id'],
            name: responseData['user']['name'],
            email: responseData['user']['email'],
            profilePicture: responseData['user']['profilePicture'],
            createdAt: DateTime.parse(responseData['user']['createdAt']),
            lastActiveAt: DateTime.now(),
            preferences: Map<String, dynamic>.from(
              responseData['user']['preferences'] ?? _getDefaultPreferences(),
            ),
            totalHabits: responseData['user']['totalHabits'] ?? 0,
            completedHabits: responseData['user']['completedHabits'] ?? 0,
            longestStreak: responseData['user']['longestStreak'] ?? 0,
          );

          // Update local storage and set as current user
          await _updateUser(user);
          await _setCurrentUser(user);
          await _trackUserAction('sign_in', {'method': 'backend'});

          return AuthResult(
            success: true,
            user: user,
            message: 'Welcome back!',
          );
        } else {
          final errorData = jsonDecode(backendResponse.body);
          // If backend fails, try local storage
          return await _signInLocally(email, password);
        }
      } catch (e) {
        // Backend connection failed, use local storage
        print('Backend signin failed: $e, using local storage');
        return await _signInLocally(email, password);
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to sign in: ${e.toString()}',
      );
    }
  }

  // Local fallback methods
  Future<AuthResult> _signUpLocally(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Check if user already exists locally
      final existingUser = await _getUserByEmail(email);
      if (existingUser != null) {
        return AuthResult(
          success: false,
          message: 'User with this email already exists',
        );
      }

      // Create new user
      final user = User(
        id: _generateUserId(),
        name: name.trim(),
        email: email.trim().toLowerCase(),
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        preferences: _getDefaultPreferences(),
      );

      // Save user data locally
      await _saveUser(user, password);
      await _setCurrentUser(user);
      await _trackUserAction('sign_up', {'method': 'local'});

      return AuthResult(
        success: true,
        user: user,
        message: 'Account created successfully (offline mode)',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to create account: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> _signInLocally(String email, String password) async {
    try {
      // Get user data from local storage
      final userData = await _getUserDataByEmail(email.trim().toLowerCase());
      if (userData == null) {
        return AuthResult(success: false, message: 'User not found');
      }

      // Verify password
      final isValid = await _verifyPassword(
        password,
        userData['hashedPassword'],
      );
      if (!isValid) {
        return AuthResult(success: false, message: 'Invalid password');
      }

      // Create user object
      final user = User.fromJson(
        userData['user'],
      ).copyWith(lastActiveAt: DateTime.now());

      // Update user data and set as current user
      await _updateUser(user);
      await _setCurrentUser(user);
      await _trackUserAction('sign_in', {'method': 'local'});

      return AuthResult(success: true, user: user, message: 'Welcome back!');
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to sign in: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    try {
      if (_currentUser != null) {
        await _trackUserAction('sign_out', {});
        await _endCurrentSession();

        // Try to notify backend about logout
        try {
          await http.post(
            Uri.parse('$baseUrl/logout'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': _currentUser!.id}),
          );
        } catch (e) {
          print('Backend logout failed: $e');
        }
      }

      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // User Management
  Future<bool> updateUserProfile({
    String? name,
    String? profilePicture,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      if (_currentUser == null) return false;

      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        profilePicture: profilePicture ?? _currentUser!.profilePicture,
        preferences: preferences ?? _currentUser!.preferences,
        lastActiveAt: DateTime.now(),
      );

      // Try to update on backend first
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/profile'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': updatedUser.id,
            'name': updatedUser.name,
            'profilePicture': updatedUser.profilePicture,
            'preferences': updatedUser.preferences,
          }),
        );

        if (response.statusCode != 200) {
          print('Backend profile update failed');
        }
      } catch (e) {
        print('Backend profile update error: $e');
      }

      // Update locally regardless of backend result
      await _updateUser(updatedUser);
      _currentUser = updatedUser;
      await _setCurrentUser(updatedUser);

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUser == null) return false;

      // Verify current password
      final userData = await _getUserDataByEmail(_currentUser!.email);
      if (userData == null) return false;

      final isValid = await _verifyPassword(
        currentPassword,
        userData['hashedPassword'],
      );
      if (!isValid) return false;

      // Validate new password
      final validation = _validatePassword(newPassword);
      if (!validation.isValid) return false;

      try {
        final response = await http.put(
          Uri.parse('$baseUrl/change-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': _currentUser!.id,
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        );

        if (response.statusCode != 200) {
          print('Backend password change failed');
        }
      } catch (e) {
        print('Backend password change error: $e');
      }

      // Update locally regardless of backend result
      final hashedPassword = _hashPassword(newPassword);
      userData['hashedPassword'] = hashedPassword;
      await _saveUserData(_currentUser!.email, userData);
      await _trackUserAction('password_change', {});

      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  // Feedback System
  Future<bool> submitFeedback({
    required String title,
    required String content,
    required FeedbackType type,
    required int rating,
  }) async {
    try {
      if (_currentUser == null) return false;

      // Get device info
      final deviceInfo = await _getDeviceInfo();

      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _currentUser!.id,
          'title': title,
          'content': content,
          'rating': rating,
          'deviceInfo': deviceInfo,
          'appVersion': '1.0.0', // Your app version
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // Add device_info_plus package and return device details
    return {
      'platform': 'mobile',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<List<UserFeedback>> getUserFeedback() async {
    try {
      if (_currentUser == null) return [];

      final prefs = await SharedPreferences.getInstance();
      final feedbackData = prefs.getStringList(_feedbackKey) ?? [];

      return feedbackData
          .map((data) => UserFeedback.fromJson(json.decode(data)))
          .where((feedback) => feedback.userId == _currentUser!.id)
          .toList();
    } catch (e) {
      print('Error getting feedback: $e');
      return [];
    }
  }

  // Session Management
  Future<void> startSession() async {
    try {
      if (_currentUser == null) return;

      final session = UserSession(
        sessionId: _generateSessionId(),
        userId: _currentUser!.id,
        startTime: DateTime.now(),
      );

      await _saveSession(session);
    } catch (e) {
      print('Error starting session: $e');
    }
  }

  Future<void> _endCurrentSession() async {
    try {
      if (_currentUser == null) return;

      final sessions = await _getUserSessions();
      final currentSession = sessions.lastWhere(
        (s) => s.userId == _currentUser!.id && s.endTime == null,
        orElse: () => throw StateError('No active session'),
      );

      final updatedSession = UserSession(
        sessionId: currentSession.sessionId,
        userId: currentSession.userId,
        startTime: currentSession.startTime,
        endTime: DateTime.now(),
        habitsCompleted: currentSession.habitsCompleted,
        screenViews: currentSession.screenViews,
        actions: currentSession.actions,
      );

      await _updateSession(updatedSession);
    } catch (e) {
      print('Error ending session: $e');
    }
  }

  // Private Methods
  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_currentUserKey);
      if (userData != null) {
        _currentUser = User.fromJson(json.decode(userData));
        await startSession();
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _setCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));
      _currentUser = user;
      await startSession();
    } catch (e) {
      print('Error setting current user: $e');
    }
  }

  Future<void> _saveUser(User user, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      final userData = {
        'user': user.toJson(),
        'hashedPassword': hashedPassword,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _saveUserData(user.email, userData);
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  Future<void> _saveUserData(
    String email,
    Map<String, dynamic> userData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allUsers = prefs.getStringList(_usersKey) ?? [];

      // Remove existing user data if any
      allUsers.removeWhere((data) {
        final user = json.decode(data);
        return user['user']['email'] == email;
      });

      // Add new user data
      allUsers.add(json.encode(userData));
      await prefs.setStringList(_usersKey, allUsers);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<Map<String, dynamic>?> _getUserDataByEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allUsers = prefs.getStringList(_usersKey) ?? [];

      for (final userData in allUsers) {
        final user = json.decode(userData);
        if (user['user']['email'] == email) {
          return user;
        }
      }

      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<User?> _getUserByEmail(String email) async {
    try {
      final userData = await _getUserDataByEmail(email);
      return userData != null ? User.fromJson(userData['user']) : null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<void> _updateUser(User user) async {
    try {
      final userData = await _getUserDataByEmail(user.email);
      if (userData != null) {
        userData['user'] = user.toJson();
        await _saveUserData(user.email, userData);
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  String _hashPassword(String password) {
    final salt = 'habitflow_salt_2025';
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> _verifyPassword(String password, String hashedPassword) async {
    return _hashPassword(password) == hashedPassword;
  }

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  ValidationResult _validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(false, 'Password is required');
    }
    if (password.length < 6) {
      return ValidationResult(false, 'Password must be at least 6 characters');
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(password)) {
      return ValidationResult(
        false,
        'Password must contain both letters and numbers',
      );
    }
    return ValidationResult(true, '');
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  Map<String, dynamic> _getDefaultPreferences() {
    return {
      'theme': 'system',
      'notifications': true,
      'reminderTime': '09:00',
      'weekStartsOn': 'monday',
      'language': 'en',
      'privacyMode': false,
    };
  }

  Future<void> _saveSession(UserSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allSessions = prefs.getStringList(_sessionsKey) ?? [];
      allSessions.add(json.encode(session.toJson()));
      await prefs.setStringList(_sessionsKey, allSessions);
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  Future<void> _updateSession(UserSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allSessions = prefs.getStringList(_sessionsKey) ?? [];

      // Find and update the session
      for (int i = 0; i < allSessions.length; i++) {
        final sessionData = json.decode(allSessions[i]);
        if (sessionData['sessionId'] == session.sessionId) {
          allSessions[i] = json.encode(session.toJson());
          break;
        }
      }

      await prefs.setStringList(_sessionsKey, allSessions);
    } catch (e) {
      print('Error updating session: $e');
    }
  }

  Future<List<UserSession>> _getUserSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allSessions = prefs.getStringList(_sessionsKey) ?? [];

      return allSessions
          .map((data) => UserSession.fromJson(json.decode(data)))
          .where((session) => session.userId == _currentUser!.id)
          .toList();
    } catch (e) {
      print('Error getting user sessions: $e');
      return [];
    }
  }

  Future<void> _trackUserAction(
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      if (_currentUser == null) return;

      final sessions = await _getUserSessions();
      if (sessions.isEmpty) return;

      final currentSession = sessions.lastWhere(
        (s) => s.userId == _currentUser!.id && s.endTime == null,
        orElse: () => throw StateError('No active session'),
      );

      final updatedActions = Map<String, dynamic>.from(currentSession.actions);
      updatedActions[action] = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
      };

      final updatedSession = UserSession(
        sessionId: currentSession.sessionId,
        userId: currentSession.userId,
        startTime: currentSession.startTime,
        endTime: currentSession.endTime,
        habitsCompleted: currentSession.habitsCompleted,
        screenViews: currentSession.screenViews,
        actions: updatedActions,
      );

      await _updateSession(updatedSession);
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking user action: $e');
      }
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({required this.success, required this.message, this.user});
}

class ValidationResult {
  final bool isValid;
  final String message;

  ValidationResult(this.isValid, this.message);
}
