import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract analytics service interface.
abstract class AnalyticsService {
  Future<void> logEvent({required String name, Map<String, Object>? parameters});
  Future<void> logScreenView({required String screenName});
  Future<void> setUserId(String? uid);
}

/// Firebase Analytics implementation.
///
/// [isEnabled] is consulted on every call so revoking consent stops collection
/// immediately at the Dart layer too, not only via the SDK flag.
class AnalyticsServiceImpl implements AnalyticsService {
  AnalyticsServiceImpl(this._analytics, {bool Function()? isEnabled})
      : _isEnabled = isEnabled ?? _alwaysEnabled;

  final FirebaseAnalytics _analytics;
  final bool Function() _isEnabled;

  static bool _alwaysEnabled() => true;

  @override
  Future<void> logEvent({required String name, Map<String, Object>? parameters}) {
    if (!_isEnabled()) return Future.value();
    return _analytics.logEvent(name: name, parameters: parameters ?? const {});
  }

  @override
  Future<void> logScreenView({required String screenName}) {
    if (!_isEnabled()) return Future.value();
    return _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> setUserId(String? uid) {
    // Clearing the id on sign-out is allowed without consent; setting one is not.
    if (!_isEnabled() && uid != null) return Future.value();
    return _analytics.setUserId(id: uid);
  }
}

/// Provider for [AnalyticsService].
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  throw UnimplementedError('Override in main.dart with Firebase Analytics instance.');
});
