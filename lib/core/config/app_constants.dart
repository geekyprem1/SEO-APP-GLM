/// App-wide constants for ShortSEO AI.
class AppConstants {
  AppConstants._();

  static const String appName = 'Tubora';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Hive box names
  static const String historyBox = 'history';
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';

  // History limits
  static const int maxHistoryItems = 200;

  // AI defaults
  static const int defaultMaxTokens = 300;
  static const double defaultTemperature = 0.7;
  static const int aiTimeoutSeconds = 15;

  // Rate limiting
  static const int rateLimitSeconds = 5;

  // Cache TTL
  static const int cacheTtlHours = 24;

  // Pagination
  static const int defaultPageSize = 20;

  // External links
  static const String privacyPolicyUrl =
      'https://shortseo.ai/privacy-policy';
  static const String termsUrl = 'https://shortseo.ai/terms';
  static const String contactEmail = 'support@shortseo.ai';

  // Cloud Functions
  static const String generateContentFunction = 'generateContent';
  static const String generateImageFunction = 'generateImage';
  static const String analyzeSeoFunction = 'analyzeSeo';
}
