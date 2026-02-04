/// Application configuration. No hardcoded secrets.
///
/// Provide NEWS_API_KEY at build time, e.g.:
///   flutter run --dart-define=NEWS_API_KEY=your_key
///   flutter build apk --dart-define=NEWS_API_KEY=your_key
class AppConfig {
  static const String newsApiKey = String.fromEnvironment('NEWS_API_KEY');

  static const String baseUrl = 'https://newsapi.org/v2';
}
