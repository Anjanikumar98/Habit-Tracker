import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/user_settings.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habit_tracker.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<String?> sendFeedback(String email, String message) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/feedback'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'message': message}),
    );

    if (response.statusCode == 201) return null;
    return jsonDecode(response.body)['error'];
  }

  Future<void> _createTables(Database db, int version) async {
    // Create habits table
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL,
        color INTEGER NOT NULL,
        tags TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        target_count INTEGER NOT NULL DEFAULT 1,
        reminder_text TEXT,
        reminder_time_hour INTEGER,
        reminder_time_minute INTEGER,
        custom_frequency_days TEXT,
        priority INTEGER NOT NULL DEFAULT 3
      )
    ''');

    // Create habit_completions table
    await db.execute('''
      CREATE TABLE habit_completions (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // Create user_settings table
    await db.execute('''
      CREATE TABLE user_settings (
        id TEXT PRIMARY KEY,
        is_dark_mode INTEGER NOT NULL DEFAULT 0,
        notifications_enabled INTEGER NOT NULL DEFAULT 1,
        reminder_time_hour INTEGER NOT NULL DEFAULT 9,
        reminder_time_minute INTEGER NOT NULL DEFAULT 0,
        week_starts_on_monday INTEGER NOT NULL DEFAULT 1,
        streak_goal INTEGER NOT NULL DEFAULT 21,
        language TEXT NOT NULL DEFAULT 'en',
        show_completion_animation INTEGER NOT NULL DEFAULT 1,
        auto_backup INTEGER NOT NULL DEFAULT 0,
        sound_enabled INTEGER NOT NULL DEFAULT 1,
        vibration_enabled INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_habit_completions_habit_id ON habit_completions(habit_id)',
    );
    await db.execute(
      'CREATE INDEX idx_habit_completions_date ON habit_completions(date)',
    );
    await db.execute('CREATE INDEX idx_habits_category ON habits(category)');
    await db.execute('CREATE INDEX idx_habits_frequency ON habits(frequency)');
  }

  // Habit operations
  Future<List<Habit>> getHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      orderBy: 'priority DESC, created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    });
  }

  Future<Habit> insertHabit(Habit habit) async {
    final db = await database;
    await db.insert('habits', habit.toMap());
    return habit;
  }

  Future<void> updateHabit(Habit habit) async {
    final db = await database;
    await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> deleteHabit(String id) async {
    final db = await database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<Habit?> getHabit(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Habit>> getHabitsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'priority DESC, created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    });
  }

  // Habit completion operations
  Future<List<HabitCompletion>> getCompletions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return HabitCompletion.fromMap(maps[i]);
    });
  }

  Future<List<HabitCompletion>> getCompletionsByHabit(String habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return HabitCompletion.fromMap(maps[i]);
    });
  }

  Future<List<HabitCompletion>> getCompletionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return HabitCompletion.fromMap(maps[i]);
    });
  }

  Future<HabitCompletion> insertCompletion(HabitCompletion completion) async {
    final db = await database;
    await db.insert('habit_completions', completion.toMap());
    return completion;
  }

  Future<void> updateCompletion(HabitCompletion completion) async {
    final db = await database;
    await db.update(
      'habit_completions',
      completion.toMap(),
      where: 'id = ?',
      whereArgs: [completion.id],
    );
  }

  Future<void> deleteCompletion(String id) async {
    final db = await database;
    await db.delete('habit_completions', where: 'id = ?', whereArgs: [id]);
  }

  Future<HabitCompletion?> getCompletionByHabitAndDate(
    String habitId,
    DateTime date,
  ) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0]; // Get date part only
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_completions',
      where: 'habit_id = ? AND date LIKE ?',
      whereArgs: [habitId, '$dateStr%'],
    );

    if (maps.isNotEmpty) {
      return HabitCompletion.fromMap(maps.first);
    }
    return null;
  }

  // User settings operations
  Future<UserSettings?> getUserSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_settings');

    if (maps.isNotEmpty) {
      return UserSettings.fromMap(maps.first);
    }
    return null;
  }

  Future<void> insertUserSettings(UserSettings settings) async {
    final db = await database;
    await db.insert('user_settings', settings.toMap());
  }

  Future<void> updateUserSettings(UserSettings settings) async {
    final db = await database;
    final result = await db.update(
      'user_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );

    // If no rows were updated, insert new settings
    if (result == 0) {
      await insertUserSettings(settings);
    }
  }

  // Statistics and analytics
  Future<int> getTotalHabits() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM habits WHERE is_active = 1',
    );
    return result.first['count'] as int;
  }

  Future<int> getTotalCompletions() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM habit_completions WHERE is_completed = 1',
    );
    return result.first['count'] as int;
  }

  Future<int> getCompletionsToday() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM habit_completions WHERE is_completed = 1 AND date LIKE ?',
      ['$today%'],
    );
    return result.first['count'] as int;
  }

  Future<Map<String, int>> getCompletionsByCategory() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT h.category, COUNT(*) as count
      FROM habit_completions hc
      JOIN habits h ON hc.habit_id = h.id
      WHERE hc.is_completed = 1
      GROUP BY h.category
    ''');

    return Map.fromIterable(
      result,
      key: (item) => item['category'] as String,
      value: (item) => item['count'] as int,
    );
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final db = await database;
    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
    final result = await db.rawQuery(
      '''
      SELECT DATE(hc.date) as date, COUNT(*) as count
      FROM habit_completions hc
      WHERE hc.is_completed = 1 AND hc.date >= ?
      GROUP BY DATE(hc.date)
      ORDER BY date
    ''',
      [oneWeekAgo.toIso8601String()],
    );

    return result;
  }

  // Database maintenance
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('habit_completions');
    await db.delete('habits');
    await db.delete('user_settings');
  }

  Future<void> exportData() async {
    // Implementation for exporting data to JSON or CSV
    // This would be used for backup functionality
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // Implementation for importing data from backup
    // This would restore user data from exported format
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
