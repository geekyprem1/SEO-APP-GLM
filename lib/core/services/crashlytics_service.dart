import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract crashlytics service interface.
abstract class CrashlyticsService {
  Future<void> recordError(Object error, StackTrace stack, {String? reason});
  Future<void> setUserId(String? uid);
  Future<void> log(String message);
}

/// Firebase Crashlytics implementation.
///
/// [isEnabled] is consulted on every call so revoking consent stops reporting
/// immediately at the Dart layer too, not only via the SDK flag.
class CrashlyticsServiceImpl implements CrashlyticsService {
  CrashlyticsServiceImpl(this._crashlytics, {bool Function()? isEnabled})
      : _isEnabled = isEnabled ?? _alwaysEnabled;

  final FirebaseCrashlytics _crashlytics;
  final bool Function() _isEnabled;

  static bool _alwaysEnabled() => true;

  @override
  Future<void> recordError(Object error, StackTrace stack, {String? reason}) {
    if (!_isEnabled()) return Future.value();
    return _crashlytics.recordError(error, stack, reason: reason);
  }

  @override
  Future<void> setUserId(String? uid) {
    // Clearing the id on sign-out is allowed without consent; setting one is not.
    if (!_isEnabled() && uid != null) return Future.value();
    return _crashlytics.setUserIdentifier(uid ?? '');
  }

  @override
  Future<void> log(String message) {
    if (!_isEnabled()) return Future.value();
    return _crashlytics.log(message);
  }
}

/// Provider for [CrashlyticsService].
final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  throw UnimplementedError('Override in main.dart with Firebase Crashlytics instance.');
});
