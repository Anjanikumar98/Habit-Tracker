import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String name;
  final String description;
  final String category;
  final String frequency; // Daily, Weekly, Monthly, Custom
  final Color color;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int targetCount; // For habits that need to be done multiple times
  final String? reminderText;
  final TimeOfDay? reminderTime;
  final List<int> customFrequencyDays; // For custom frequency (weekdays)
  final int priority; // 1-5, where 5 is highest priority

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.frequency,
    required this.color,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
    this.targetCount = 1,
    this.reminderText,
    this.reminderTime,
    this.customFrequencyDays = const [],
    this.priority = 3,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Copy with method for immutability
  Habit copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? frequency,
    Color? color,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? targetCount,
    String? reminderText,
    TimeOfDay? reminderTime,
    List<int>? customFrequencyDays,
    int? priority,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isActive: isActive ?? this.isActive,
      targetCount: targetCount ?? this.targetCount,
      reminderText: reminderText ?? this.reminderText,
      reminderTime: reminderTime ?? this.reminderTime,
      customFrequencyDays: customFrequencyDays ?? this.customFrequencyDays,
      priority: priority ?? this.priority,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'frequency': frequency,
      'color': color.value,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'targetCount': targetCount,
      'reminderText': reminderText,
      'reminderTimeHour': reminderTime?.hour,
      'reminderTimeMinute': reminderTime?.minute,
      'customFrequencyDays': customFrequencyDays,
      'priority': priority,
    };
  }

  // Create from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      frequency: json['frequency'] as String,
      color: Color(json['color'] as int),
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      targetCount: json['targetCount'] as int? ?? 1,
      reminderText: json['reminderText'] as String?,
      reminderTime:
          json['reminderTimeHour'] != null && json['reminderTimeMinute'] != null
              ? TimeOfDay(
                hour: json['reminderTimeHour'] as int,
                minute: json['reminderTimeMinute'] as int,
              )
              : null,
      customFrequencyDays: List<int>.from(
        json['customFrequencyDays'] as List? ?? [],
      ),
      priority: json['priority'] as int? ?? 3,
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'frequency': frequency,
      'color': color.value,
      'tags': tags.join(','),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'target_count': targetCount,
      'reminder_text': reminderText,
      'reminder_time_hour': reminderTime?.hour,
      'reminder_time_minute': reminderTime?.minute,
      'custom_frequency_days': customFrequencyDays.join(','),
      'priority': priority,
    };
  }

  // Create from database map
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      frequency: map['frequency'] as String,
      color: Color(map['color'] as int),
      tags:
          (map['tags'] as String?)
              ?.split(',')
              .where((tag) => tag.isNotEmpty)
              .toList() ??
          [],
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isActive: (map['is_active'] as int) == 1,
      targetCount: map['target_count'] as int? ?? 1,
      reminderText: map['reminder_text'] as String?,
      reminderTime:
          map['reminder_time_hour'] != null &&
                  map['reminder_time_minute'] != null
              ? TimeOfDay(
                hour: map['reminder_time_hour'] as int,
                minute: map['reminder_time_minute'] as int,
              )
              : null,
      customFrequencyDays:
          (map['custom_frequency_days'] as String?)
              ?.split(',')
              .where((day) => day.isNotEmpty)
              .map((day) => int.parse(day))
              .toList() ??
          [],
      priority: map['priority'] as int? ?? 3,
    );
  }

  // Utility methods
  String get colorHex {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  String get formattedTags {
    return tags.join(', ');
  }

  String get priorityLabel {
    switch (priority) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Very High';
      default:
        return 'Medium';
    }
  }

  IconData get priorityIcon {
    switch (priority) {
      case 1:
        return Icons.keyboard_arrow_down;
      case 2:
        return Icons.remove;
      case 3:
        return Icons.horizontal_rule;
      case 4:
        return Icons.keyboard_arrow_up;
      case 5:
        return Icons.keyboard_double_arrow_up;
      default:
        return Icons.horizontal_rule;
    }
  }

  String get frequencyDisplayName {
    switch (frequency) {
      case 'Daily':
        return 'Every day';
      case 'Weekly':
        return 'Once a week';
      case 'Monthly':
        return 'Once a month';
      case 'Custom':
        return 'Custom schedule';
      default:
        return frequency;
    }
  }

  bool get hasReminder {
    return reminderTime != null;
  }

  String get formattedReminderTime {
    if (reminderTime == null) return 'No reminder';
    final hour = reminderTime!.hour;
    final minute = reminderTime!.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  bool shouldShowToday(DateTime date) {
    switch (frequency) {
      case 'Daily':
        return true;
      case 'Weekly':
        return date.weekday == 1; // Monday
      case 'Monthly':
        return date.day == 1; // First day of month
      case 'Custom':
        return customFrequencyDays.contains(date.weekday);
      default:
        return true;
    }
  }

  List<String> get weekdayNames {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return customFrequencyDays.map((day) => names[day - 1]).toList();
  }

  int get daysUntilNext {
    if (frequency == 'Daily') return 1;

    final now = DateTime.now();
    switch (frequency) {
      case 'Weekly':
        final daysUntilMonday = (8 - now.weekday) % 7;
        return daysUntilMonday == 0 ? 7 : daysUntilMonday;
      case 'Monthly':
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        return nextMonth.difference(now).inDays;
      case 'Custom':
        if (customFrequencyDays.isEmpty) return 1;
        final nextDay = customFrequencyDays.firstWhere(
          (day) => day > now.weekday,
          orElse: () => customFrequencyDays.first,
        );
        return nextDay > now.weekday
            ? nextDay - now.weekday
            : 7 - now.weekday + nextDay;
      default:
        return 1;
    }
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, category: $category, frequency: $frequency, isActive: $isActive, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.category == category &&
        other.frequency == frequency &&
        other.color == color &&
        other.isActive == isActive &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        category.hashCode ^
        frequency.hashCode ^
        color.hashCode ^
        isActive.hashCode ^
        priority.hashCode;
  }
}
