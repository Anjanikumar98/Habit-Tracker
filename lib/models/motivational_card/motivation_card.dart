import 'package:flutter/material.dart';
import 'package:habit_tracker/services/api_services/motivational_service.dart';
import 'package:habit_tracker/utlis/theme.dart';

class MotivationCard extends StatefulWidget {
  const MotivationCard({super.key});

  @override
  State<MotivationCard> createState() => _MotivationCardState();
}

class _MotivationCardState extends State<MotivationCard> {
  Map<String, String>? _quote;
  bool _loading = false;

  Future<void> _loadQuote() async {
    setState(() => _loading = true);
    try {
      final quote = await MotivationalService.getMotivationalQuote();
      setState(() => _quote = quote);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load quote 😢')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _quote == null
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Need a boost?', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _loading ? null : _loadQuote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.format_quote),
                      label:
                          _loading
                              ? const Text('Loading...')
                              : const Text('Tap for Motivation'),
                    ),
                  ],
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote, color: colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(
                      '"${_quote!['text']}"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '- ${_quote!['author']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
