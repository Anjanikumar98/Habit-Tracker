import 'package:flutter/material.dart';
import '../../../services/analytics_service.dart';

class ProductivityScoreWidget extends StatelessWidget {
  final AnalyticsService _analyticsService = AnalyticsService();

  ProductivityScoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _analyticsService.getProductivityScore(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Error loading productivity score'),
            ),
          );
        }

        final score = snapshot.data!;
        final color = _getScoreColor(score);

        return Card(
          elevation: 3,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Productivity Score',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          score.toStringAsFixed(0),
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          'Score',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    _getScoreMessage(score),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getScoreDescription(score),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.lightGreen;
    } else if (score >= 40) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }

  String _getScoreMessage(double score) {
    if (score >= 80) {
      return 'Excellent! Keep up the great work!';
    } else if (score >= 60) {
      return 'Good job! There\'s room to improve.';
    } else if (score >= 40) {
      return 'You\'re getting there. Let\'s focus more.';
    } else {
      return 'Needs improvement. Let\'s build better habits!';
    }
  }

  String _getScoreDescription(double score) {
    if (score >= 80) {
      return 'Your productivity levels are outstanding. You have strong focus and consistency.';
    } else if (score >= 60) {
      return 'You are doing well, but there are areas where you can become even more productive.';
    } else if (score >= 40) {
      return 'You have some productivity, but inconsistency or distractions might be holding you back.';
    } else {
      return 'Your productivity is currently low. Try revisiting your goals and routines.';
    }
  }
}
