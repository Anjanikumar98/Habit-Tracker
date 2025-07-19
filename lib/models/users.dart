class User {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic> preferences;
  final int totalHabits;
  final int completedHabits;
  final int longestStreak;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    required this.createdAt,
    required this.lastActiveAt,
    this.preferences = const {},
    this.totalHabits = 0,
    this.completedHabits = 0,
    this.longestStreak = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'preferences': preferences,
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'longestStreak': longestStreak,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastActiveAt:
          DateTime.tryParse(json['lastActiveAt'] ?? '') ?? DateTime.now(),
      preferences:
          json['preferences'] is Map
              ? Map<String, dynamic>.from(json['preferences'])
              : {},
      totalHabits: json['totalHabits'] ?? 0,
      completedHabits: json['completedHabits'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
    int? totalHabits,
    int? completedHabits,
    int? longestStreak,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      preferences: preferences ?? this.preferences,
      totalHabits: totalHabits ?? this.totalHabits,
      completedHabits: completedHabits ?? this.completedHabits,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}

class UserFeedback {
  final String id;
  final String userId;
  final String title;
  final String content;
  final FeedbackType type;
  final int rating;
  final DateTime createdAt;
  final bool isResolved;

  UserFeedback({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.rating,
    required this.createdAt,
    this.isResolved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'type': type.toString().split('.').last,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'isResolved': isResolved,
    };
  }

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    return UserFeedback(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      type: FeedbackType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      rating: json['rating'],
      createdAt: DateTime.parse(json['createdAt']),
      isResolved: json['isResolved'] ?? false,
    );
  }
}

enum FeedbackType { bug, feature, improvement, general, compliment }


class UserSession {
  final String sessionId;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int habitsCompleted;
  final int screenViews;
  final Map<String, dynamic> actions;

  UserSession({
    required this.sessionId,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.habitsCompleted = 0,
    this.screenViews = 0,
    this.actions = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'habitsCompleted': habitsCompleted,
      'screenViews': screenViews,
      'actions': actions,
    };
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      sessionId: json['sessionId'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      habitsCompleted: json['habitsCompleted'] ?? 0,
      screenViews: json['screenViews'] ?? 0,
      actions: Map<String, dynamic>.from(json['actions'] ?? {}),
    );
  }
}

