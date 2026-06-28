import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'exceptions.dart';
import 'failures.dart';

/// Centralized error handler that converts exceptions → [Failure]s
/// and forwards reportable errors to Crashlytics (via injected callback).
class ErrorHandler {
  ErrorHandler({this.recordCrashlytics});

  /// Optional callback to report errors to Crashlytics.
  final void Function(Object error, StackTrace stack, {String? reason})? recordCrashlytics;

  /// Converts any thrown object into a [Failure].
  Failure convert(Object error, [StackTrace? stack]) {
    final failure = _mapToFailure(error);

    // Report unexpected failures to Crashlytics.
    if (failure.shouldReport) {
      recordCrashlytics?.call(error, stack ?? StackTrace.current, reason: failure.code);
    }
    return failure;
  }

  Failure _mapToFailure(Object error) {
    // Already a Failure — pass through.
    if (error is Failure) return error;

    // App exceptions → mapped failures.
    if (error is NetworkException) {
      return NetworkFailure(message: error.message);
    }
    if (error is TimeoutException) {
      return TimeoutFailure(message: error.message);
    }
    if (error is ApiException) {
      return ApiFailure(message: error.message, code: error.code, statusCode: error.statusCode);
    }
    if (error is FirebaseException) {
      return FirebaseFailure(message: error.message, code: error.code);
    }
    if (error is QuotaExceededException) {
      return QuotaExceededFailure(feature: error.feature, message: error.message);
    }
    if (error is BudgetExceededException) {
      return BudgetExceededFailure(message: error.message);
    }
    if (error is RateLimitException) {
      return RateLimitFailure(message: error.message);
    }
    if (error is ValidationException) {
      return ValidationFailure(fieldErrors: error.fieldErrors, message: error.message);
    }

    // Dio errors.
    if (error is DioException) {
      return _mapDioError(error);
    }

    // Firebase auth errors.
    if (error is firebase_auth.FirebaseAuthException) {
      return FirebaseFailure(
        message: _authErrorMessage(error),
        code: error.code,
      );
    }

    // Firebase core errors.
    if (error is firebase_core.FirebaseException) {
      return FirebaseFailure(message: error.message ?? 'Firebase error', code: error.code);
    }

    // Fallback.
    return UnknownFailure(message: error.toString());
  }

  Failure _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'Something went wrong on our end.';
        if (data is Map && data['message'] is String) {
          message = data['message'] as String;
        }
        // Cloud Function quota / budget / rate-limit signals.
        if (code == 429) return RateLimitFailure(message: message);
        if (code == 402) return BudgetExceededFailure(message: message);
        if (code == 403 && message.toLowerCase().contains('quota')) {
          return QuotaExceededFailure(feature: 'feature', message: message);
        }
        return ApiFailure(message: message, statusCode: code);
      case DioExceptionType.cancel:
        return const CancelledFailure();
      case DioExceptionType.unknown:
        if (error.error != null) {
          if (error.error.toString().contains('Socket')) {
            return const NetworkFailure();
          }
        }
        return UnknownFailure(message: error.message ?? 'Unknown error.');
      case DioExceptionType.badCertificate:
        return const ApiFailure(message: 'Security error.');
    }
  }

  String _authErrorMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found. Please sign in again.';
      case 'wrong-password':
        return 'Incorrect credentials.';
      case 'invalid-credential':
        return 'Invalid credentials.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return error.message ?? 'Authentication error.';
    }
  }
}
