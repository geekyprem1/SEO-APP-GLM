import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract analytics service interface.
abstract class AnalyticsService {
  Future<void> logEvent({required String name, Map<String, Object>? parameters});
  Future<void> logScreenView({required String screenName});
  Future<void> setUserId(String? uid);
}

/// Firebase Analytics implementation.
class AnalyticsServiceImpl implements AnalyticsService {
  AnalyticsServiceImpl(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent({required String name, Map<String, Object>? parameters}) {
    return _analytics.logEvent(name: name, parameters: parameters ?? const {});
  }

  @override
  Future<void> logScreenView({required String screenName}) {
    return _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> setUserId(String? uid) {
    return _analytics.setUserId(id: uid);
  }
}

/// Provider for [AnalyticsService].
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  throw UnimplementedError('Override in main.dart with Firebase Analytics instance.');
});
