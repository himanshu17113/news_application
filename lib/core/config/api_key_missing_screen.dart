import 'package:flutter/material.dart';

/// Shown when [AppConfig.newsApiKey] is missing at startup.
/// Tells the user how to provide the key so errors are obvious and actionable.
class ApiKeyMissingScreen extends StatelessWidget {
  const ApiKeyMissingScreen({super.key});

  static const String _message = 'News API key not set. Run with:\n\n'
      '--dart-define=NEWS_API_KEY=your_key';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.key_off_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Configure API key',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SelectableText(
                  _message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                    fontFamilyFallback: ['Menlo', 'monospace'],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
