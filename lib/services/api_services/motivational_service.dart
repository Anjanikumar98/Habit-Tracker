import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MotivationalService {
  static const String _quotesApi = 'https://api.quotable.io/random';
  static const String _zenQuotesApi = 'https://zenquotes.io/api/random';
  static const String _adviceApi = 'https://api.adviceslip.com/advice';
  static const String _affirmationsApi = 'https://www.affirmations.dev/';

  // Cache for offline support
  static final List<Map<String, String>> _cachedQuotes = [
    {
      'text': 'The secret of getting ahead is getting started.',
      'author': 'Mark Twain',
      'category': 'motivation',
    },
    {
      'text':
          'Success is the sum of small efforts repeated day in and day out.',
      'author': 'Robert Collier',
      'category': 'consistency',
    },
    {
      'text': 'Focus on being productive instead of busy.',
      'author': 'Tim Ferriss',
      'category': 'focus',
    },
    {
      'text': 'Progress, not perfection.',
      'author': 'Unknown',
      'category': 'habits',
    },
    {
      'text':
          'You are what you repeatedly do. Excellence is not an act, but a habit.',
      'author': 'Aristotle',
      'category': 'habits',
    },
  ];

  static final List<Map<String, String>> _habitTips = [
    {
      'title': 'Start Small',
      'content':
          'Begin with habits that take less than 2 minutes to complete. This makes them easy to start and builds momentum.',
      'category': 'consistency',
    },
    {
      'title': 'Stack Your Habits',
      'content':
          'Link new habits to existing ones. After I [current habit], I will [new habit].',
      'category': 'building',
    },
    {
      'title': 'Focus on Systems',
      'content':
          'Don\'t focus on goals, focus on systems. Goals are about the results, systems are about the process.',
      'category': 'focus',
    },
    {
      'title': 'Track Your Progress',
      'content':
          'What gets measured gets managed. Keep a simple record of your habit completion.',
      'category': 'tracking',
    },
    {
      'title': 'Environmental Design',
      'content':
          'Make good habits obvious and bad habits invisible by designing your environment.',
      'category': 'environment',
    },
  ];

  // Get motivational quote
  static Future<Map<String, String>> getMotivationalQuote() async {
    try {
      // Try multiple APIs for better reliability
      final response = await _tryMultipleQuoteAPIs();
      return response;
    } catch (e) {
      debugPrint('Error fetching quote: $e');
      return _getRandomCachedQuote();
    }
  }

  // Get daily affirmation
  static Future<Map<String, String>> getDailyAffirmation() async {
    try {
      final response = await http
          .get(
            Uri.parse(_affirmationsApi),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'text': data['affirmation'] ?? 'You are capable of amazing things!',
          'author': 'Daily Affirmation',
          'category': 'affirmation',
        };
      }
    } catch (e) {
      debugPrint('Error fetching affirmation: $e');
    }

    return {
      'text': 'Every small step forward is progress worth celebrating.',
      'author': 'Daily Affirmation',
      'category': 'affirmation',
    };
  }

  // Get habit-building tip
  static Map<String, String> getHabitTip() {
    final random = Random();
    return _habitTips[random.nextInt(_habitTips.length)];
  }

  // Get advice
  static Future<Map<String, String>> getAdvice() async {
    try {
      final response = await http
          .get(Uri.parse(_adviceApi), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'text': data['slip']['advice'] ?? 'Take it one day at a time.',
          'author': 'Advice Slip',
          'category': 'advice',
        };
      }
    } catch (e) {
      debugPrint('Error fetching advice: $e');
    }

    return {
      'text': 'Small daily improvements lead to stunning results.',
      'author': 'Advice',
      'category': 'advice',
    };
  }

  // Get category-specific content
  static Future<Map<String, String>> getContentByCategory(
    String category,
  ) async {
    switch (category.toLowerCase()) {
      case 'consistency':
        return await _getConsistencyContent();
      case 'focus':
        return await _getFocusContent();
      case 'motivation':
        return await getMotivationalQuote();
      case 'habits':
        return _getHabitContent();
      default:
        return await getMotivationalQuote();
    }
  }

  // Get weekly habit insights
  static List<Map<String, String>> getWeeklyInsights() {
    return [
      {
        'title': 'The 1% Rule',
        'content':
            'Getting 1% better every day leads to 37x improvement over a year.',
        'category': 'improvement',
      },
      {
        'title': 'Consistency Beats Perfection',
        'content':
            'It\'s better to do something small every day than to do something big occasionally.',
        'category': 'consistency',
      },
      {
        'title': 'Environment Matters',
        'content':
            'Your environment shapes your behavior more than your motivation does.',
        'category': 'environment',
      },
      {
        'title': 'The Power of Identity',
        'content':
            'Every action is a vote for the type of person you wish to become.',
        'category': 'identity',
      },
    ];
  }

  // Private helper methods
  static Future<Map<String, String>> _tryMultipleQuoteAPIs() async {
    // Try Quotable API first
    try {
      final response = await http
          .get(
            Uri.parse('$_quotesApi?tags=motivational,success,perseverance'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'text': data['content'] ?? '',
          'author': data['author'] ?? 'Unknown',
          'category': 'motivation',
        };
      }
    } catch (e) {
      debugPrint('Quotable API failed: $e');
    }

    // Try ZenQuotes API as fallback
    try {
      final response = await http
          .get(
            Uri.parse(_zenQuotesApi),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          return {
            'text': data[0]['q'] ?? '',
            'author': data[0]['a'] ?? 'Unknown',
            'category': 'motivation',
          };
        }
      }
    } catch (e) {
      debugPrint('ZenQuotes API failed: $e');
    }

    // Fallback to cached quotes
    return _getRandomCachedQuote();
  }

  static Map<String, String> _getRandomCachedQuote() {
    final random = Random();
    return _cachedQuotes[random.nextInt(_cachedQuotes.length)];
  }

  static Future<Map<String, String>> _getConsistencyContent() async {
    final consistencyQuotes = [
      {
        'text':
            'Success is nothing more than a few simple disciplines, practiced every day.',
        'author': 'Jim Rohn',
        'category': 'consistency',
      },
      {
        'text': 'The secret of getting ahead is getting started.',
        'author': 'Mark Twain',
        'category': 'consistency',
      },
    ];

    final random = Random();
    return consistencyQuotes[random.nextInt(consistencyQuotes.length)];
  }

  static Future<Map<String, String>> _getFocusContent() async {
    final focusQuotes = [
      {
        'text':
            'The successful warrior is the average man with laser-like focus.',
        'author': 'Bruce Lee',
        'category': 'focus',
      },
      {
        'text': 'Focus on being productive instead of busy.',
        'author': 'Tim Ferriss',
        'category': 'focus',
      },
    ];

    final random = Random();
    return focusQuotes[random.nextInt(focusQuotes.length)];
  }

  static Map<String, String> _getHabitContent() {
    final habitQuotes = [
      {
        'text':
            'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
        'author': 'Aristotle',
        'category': 'habits',
      },
      {
        'text':
            'Motivation is what gets you started. Habit is what keeps you going.',
        'author': 'Jim Ryun',
        'category': 'habits',
      },
    ];

    final random = Random();
    return habitQuotes[random.nextInt(habitQuotes.length)];
  }

  // Get personalized content based on user's habit completion rate
  static Map<String, String> getPersonalizedContent(double completionRate) {
    if (completionRate >= 0.8) {
      return {
        'text': 'You\'re crushing it! Keep up the amazing consistency.',
        'author': 'Personal Insight',
        'category': 'celebration',
      };
    } else if (completionRate >= 0.6) {
      return {
        'text': 'Great progress! Small improvements compound over time.',
        'author': 'Personal Insight',
        'category': 'encouragement',
      };
    } else if (completionRate >= 0.4) {
      return {
        'text': 'Every expert was once a beginner. Keep pushing forward!',
        'author': 'Personal Insight',
        'category': 'motivation',
      };
    } else {
      return {
        'text': 'Start small, stay consistent. You\'ve got this!',
        'author': 'Personal Insight',
        'category': 'support',
      };
    }
  }
}
