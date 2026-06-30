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

  // External links (live on the Tubora marketing site).
  // Apex domain (no `www.`): the site is published on GitHub Pages with the
  // custom domain `tubora.online`, and the `www.` host does not resolve. The
  // privacy URL MUST be publicly reachable or Google Play rejects the listing.
  static const String privacyPolicyUrl =
      'https://tubora.online/privacy.html';
  static const String disclaimerUrl =
      'https://tubora.online/disclaimer.html';
  static const String contactEmail = 'geekyprem4@gmail.com';

  // Cloud Functions
  static const String generateContentFunction = 'generateContent';
  static const String generateImageFunction = 'generateImage';
  static const String analyzeSeoFunction = 'analyzeSeo';
}
