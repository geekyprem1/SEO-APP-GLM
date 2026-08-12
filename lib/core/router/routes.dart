/// Centralized route path constants.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/';
  static const String title = '/title';
  static const String hashtags = '/hashtags';
  static const String description = '/description';
  static const String content = '/content';
  static const String viralIdeas = '/viral-ideas';
  static const String trending = '/trending';
  static const String thumbnail = '/thumbnail';
  static const String seo = '/seo';
  static const String hook = '/hook';
  static const String captions = '/captions';
  static const String chapters = '/chapters';
  static const String cta = '/cta';
  static const String competitor = '/competitor';
  static const String series = '/series';
  static const String history = '/history';
  static const String historyDetail = '/history/:id';
  static const String settings = '/settings';

  /// Builds a history detail path with an ID.
  static String historyDetailFor(String id) => '/history/$id';
}
