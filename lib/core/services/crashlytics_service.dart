import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract crashlytics service interface.
abstract class CrashlyticsService {
  Future<void> recordError(Object error, StackTrace stack, {String? reason});
  Future<void> setUserId(String? uid);
  Future<void> log(String message);
}

/// Firebase Crashlytics implementation.
class CrashlyticsServiceImpl implements CrashlyticsService {
  CrashlyticsServiceImpl(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordError(Object error, StackTrace stack, {String? reason}) {
    return _crashlytics.recordError(error, stack, reason: reason);
  }

  @override
  Future<void> setUserId(String? uid) {
    return _crashlytics.setUserIdentifier(uid ?? '');
  }

  @override
  Future<void> log(String message) {
    return _crashlytics.log(message);
  }
}

/// Provider for [CrashlyticsService].
final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  throw UnimplementedError('Override in main.dart with Firebase Crashlytics instance.');
});
