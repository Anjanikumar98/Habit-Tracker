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
  bool _isBackendAvailable = false;

  // Backend URL - change this to your actual backend URL
  final String baseUrl = 'http://localhost:3000';

  // Initialize service
  Future<void> initialize() async {
    await _loadCurrentUser();
    await _checkBackendStatus();
  }

  Future<void> _checkBackendStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      _isBackendAvailable = response.statusCode == 200;
    } catch (e) {
      _isBackendAvailable = false;
      if (kDebugMode) {
        print('Backend unavailable, using local storage: $e');
      }
    }
  }

  // Authentication Methods with Backend Integration
  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (name.trim().isEmpty) {
        return AuthResult(success: false, message: 'Name is required');
      }

      if (email.trim().isEmpty) {
        return AuthResult(success: false, message: 'Email is required');
      }

      if (!_isValidEmail(email)) {
        return AuthResult(
          success: false,
          message: 'Please enter a valid email address',
        );
      }

      final passwordValidation = _validatePassword(password);
      if (!passwordValidation.isValid) {
        return AuthResult(success: false, message: passwordValidation.message);
      }

      // Check if user already exists locally first
      final existingUser = await _getUserByEmail(email.trim().toLowerCase());
      if (existingUser != null) {
        return AuthResult(
          success: false,
          message: 'An account with this email already exists',
        );
      }

      // Try backend first if available
      if (_isBackendAvailable) {
        try {
          final response = await http
              .post(
                Uri.parse('$baseUrl/api/auth/signup'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'name': name.trim(),
                  'email': email.trim().toLowerCase(),
                  'password': password,
                  'deviceInfo': await _getDeviceInfo(),
                }),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 201) {
            final data = jsonDecode(response.body);
            final user = User.fromJson(data['user']);

            await _setCurrentUser(user);
            await _trackUserAction('sign_up', {'method': 'backend'});

            return AuthResult(
              success: true,
              user: user,
              message: 'Account created successfully!',
            );
          } else {
            final errorData = jsonDecode(response.body);
            // If backend signup fails, try local
            return await _signUpLocally(name, email, password);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Backend signup failed: $e, using local storage');
          }
          return await _signUpLocally(name, email, password);
        }
      } else {
        return await _signUpLocally(name, email, password);
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to create account: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
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

      // Try backend first if available
      if (_isBackendAvailable) {
        try {
          final backendResponse = await http
              .post(
                Uri.parse('$baseUrl/api/auth/signin'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'email': email.trim().toLowerCase(),
                  'password': password,
                  'deviceInfo': await _getDeviceInfo(),
                }),
              )
              .timeout(const Duration(seconds: 10));

          if (backendResponse.statusCode == 200) {
            final responseData = jsonDecode(backendResponse.body);

            // Create user from backend response
            final user = User.fromJson(
              responseData['user'],
            ).copyWith(lastActiveAt: DateTime.now());

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
            // If backend fails, try local storage
            return await _signInLocally(email, password);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Backend signin failed: $e, using local storage');
          }
          return await _signInLocally(email, password);
        }
      } else {
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
        message: 'Account created successfully!',
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
        return AuthResult(
          success: false,
          message: 'No account found with this email',
        );
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
        if (_isBackendAvailable) {
          try {
            await http
                .post(
                  Uri.parse('$baseUrl/api/auth/signout'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'userId': _currentUser!.id}),
                )
                .timeout(const Duration(seconds: 5));
          } catch (e) {
            if (kDebugMode) {
              print('Backend logout failed: $e');
            }
          }
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

      // Try to update on backend first if available
      if (_isBackendAvailable) {
        try {
          final response = await http
              .put(
                Uri.parse('$baseUrl/api/user/profile'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'userId': updatedUser.id,
                  'name': updatedUser.name,
                  'profilePicture': updatedUser.profilePicture,
                  'preferences': updatedUser.preferences,
                }),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode != 200) {
            if (kDebugMode) {
              print('Backend profile update failed');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Backend profile update error: $e');
          }
        }
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

      // Validate new password
      final validation = _validatePassword(newPassword);
      if (!validation.isValid) return false;

      // Verify current password
      final userData = await _getUserDataByEmail(_currentUser!.email);
      if (userData == null) return false;

      final isValid = await _verifyPassword(
        currentPassword,
        userData['hashedPassword'],
      );
      if (!isValid) return false;

      // Try to update on backend first if available
      if (_isBackendAvailable) {
        try {
          final response = await http
              .put(
                Uri.parse('$baseUrl/api/user/change-password'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'userId': _currentUser!.id,
                  'currentPassword': currentPassword,
                  'newPassword': newPassword,
                }),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode != 200) {
            if (kDebugMode) {
              print('Backend password change failed');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Backend password change error: $e');
          }
        }
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

      final feedback = UserFeedback(
        id: _generateFeedbackId(),
        userId: _currentUser!.id,
        title: title.trim(),
        content: content.trim(),
        type: type,
        rating: rating.clamp(1, 5),
        createdAt: DateTime.now(),
      );

      // Try backend first if available
      if (_isBackendAvailable) {
        try {
          final response = await http
              .post(
                Uri.parse('$baseUrl/api/feedback'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'userId': _currentUser!.id,
                  'title': feedback.title,
                  'content': feedback.content,
                  'type': type.toString().split('.').last,
                  'rating': feedback.rating,
                  'deviceInfo': await _getDeviceInfo(),
                  'appVersion': '1.0.0',
                }),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 201) {
            // Also save locally for offline access
            await _saveFeedbackLocally(feedback);
            return true;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Backend feedback submission failed: $e');
          }
        }
      }

      // Save locally if backend fails or unavailable
      await _saveFeedbackLocally(feedback);
      return true;
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  Future<void> _saveFeedbackLocally(UserFeedback feedback) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbackList = prefs.getStringList(_feedbackKey) ?? [];
      feedbackList.add(jsonEncode(feedback.toJson()));
      await prefs.setStringList(_feedbackKey, feedbackList);
    } catch (e) {
      print('Error saving feedback locally: $e');
    }
  }

  String _generateFeedbackId() {
    return 'feedback_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      return {
        'platform': Platform.operatingSystem,
        'version': Platform.version,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'platform': 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<List<UserFeedback>> getUserFeedback() async {
    try {
      if (_currentUser == null) return [];

      final prefs = await SharedPreferences.getInstance();
      final feedbackData = prefs.getStringList(_feedbackKey) ?? [];

      return feedbackData
          .map((data) => UserFeedback.fromJson(jsonDecode(data)))
          .where((feedback) => feedback.userId == _currentUser!.id)
          .toList();
    } catch (e) {
      print('Error getting feedback: $e');
      return [];
    }
  }

  // Public method to get user by email (for AuthProvider)
  Future<User?> getUserByEmail(String email) async {
    return await _getUserByEmail(email);
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
      if (sessions.isEmpty) return;

      final currentSession =
          sessions
              .where((s) => s.userId == _currentUser!.id && s.endTime == null)
              .lastOrNull;

      if (currentSession == null) return;

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
        _currentUser = User.fromJson(jsonDecode(userData));
        await startSession();
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _setCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
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
        try {
          final user = jsonDecode(data);
          return user['user']['email'] == email;
        } catch (e) {
          return false; // Keep invalid entries for now
        }
      });

      // Add new user data
      allUsers.add(jsonEncode(userData));
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
        try {
          final user = jsonDecode(userData);
          if (user['user']['email'] == email) {
            return user;
          }
        } catch (e) {
          // Skip invalid JSON entries
          continue;
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
        userData['lastUpdated'] = DateTime.now().toIso8601String();
        await _saveUserData(user.email, userData);
      }
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  String _hashPassword(String password) {
    try {
      final salt = 'habitflow_salt_2025_${DateTime.now().year}';
      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      // Fallback to simple hash if crypto fails
      return password.codeUnits.map((e) => e * 7 % 256).join();
    }
  }

  Future<bool> _verifyPassword(String password, String hashedPassword) async {
    try {
      return _hashPassword(password) == hashedPassword;
    } catch (e) {
      return false;
    }
  }

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  ValidationResult _validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(false, 'Password is required');
    }
    if (password.length < 6) {
      return ValidationResult(
        false,
        'Password must be at least 6 characters long',
      );
    }
    if (password.length > 128) {
      return ValidationResult(false, 'Password is too long');
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(password)) {
      return ValidationResult(
        false,
        'Password must contain both letters and numbers',
      );
    }
    return ValidationResult(true, 'Password is valid');
  }

  bool _isValidEmail(String email) {
    if (email.trim().isEmpty) return false;
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    ).hasMatch(email.trim());
  }

  Map<String, dynamic> _getDefaultPreferences() {
    return {
      'theme': 'system',
      'notifications': true,
      'reminderTime': '09:00',
      'weekStartsOn': 'monday',
      'language': 'en',
      'privacyMode': false,
      'soundEnabled': true,
      'vibrationEnabled': true,
      'dailyGoalReminder': true,
      'weeklyReportEnabled': true,
    };
  }

  Future<void> _saveSession(UserSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allSessions = prefs.getStringList(_sessionsKey) ?? [];
      allSessions.add(jsonEncode(session.toJson()));

      // Keep only last 50 sessions to prevent storage bloat
      if (allSessions.length > 50) {
        allSessions.removeRange(0, allSessions.length - 50);
      }

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
        try {
          final sessionData = jsonDecode(allSessions[i]);
          if (sessionData['sessionId'] == session.sessionId) {
            allSessions[i] = jsonEncode(session.toJson());
            break;
          }
        } catch (e) {
          // Skip invalid session data
          continue;
        }
      }

      await prefs.setStringList(_sessionsKey, allSessions);
    } catch (e) {
      print('Error updating session: $e');
    }
  }

  Future<List<UserSession>> _getUserSessions() async {
    try {
      if (_currentUser == null) return [];

      final prefs = await SharedPreferences.getInstance();
      final allSessions = prefs.getStringList(_sessionsKey) ?? [];

      final userSessions = <UserSession>[];

      for (final sessionData in allSessions) {
        try {
          final session = UserSession.fromJson(jsonDecode(sessionData));
          if (session.userId == _currentUser!.id) {
            userSessions.add(session);
          }
        } catch (e) {
          // Skip invalid session data
          continue;
        }
      }

      return userSessions;
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

      final currentSession =
          sessions
              .where((s) => s.userId == _currentUser!.id && s.endTime == null)
              .lastOrNull;

      if (currentSession == null) return;

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

  // Cleanup methods
  Future<void> clearOldData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clean up old sessions (keep only last 30 days)
      final allSessions = prefs.getStringList(_sessionsKey) ?? [];
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      final validSessions = <String>[];
      for (final sessionData in allSessions) {
        try {
          final session = UserSession.fromJson(jsonDecode(sessionData));
          if (session.startTime.isAfter(cutoffDate)) {
            validSessions.add(sessionData);
          }
        } catch (e) {
          // Skip invalid session data
          continue;
        }
      }

      await prefs.setStringList(_sessionsKey, validSessions);

      // Clean up old analytics events
      final eventsJson = prefs.getString('analytics_events') ?? '[]';
      final events = List<Map<String, dynamic>>.from(jsonDecode(eventsJson));

      final validEvents =
          events.where((event) {
            try {
              final timestamp = DateTime.parse(event['timestamp']);
              return timestamp.isAfter(cutoffDate);
            } catch (e) {
              return false;
            }
          }).toList();

      await prefs.setString('analytics_events', jsonEncode(validEvents));
    } catch (e) {
      print('Error cleaning up old data: $e');
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({required this.success, required this.message, this.user});

  @override
  String toString() {
    return 'AuthResult(success: $success, message: $message, user: ${user?.email})';
  }
}

class ValidationResult {
  final bool isValid;
  final String message;

  ValidationResult(this.isValid, this.message);

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, message: $message)';
  }
}

extension ListExtension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
