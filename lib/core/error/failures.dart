/// Base failure type for all domain errors.
/// All failures carry a user-friendly [message] and an optional [code].
sealed class Failure {
  const Failure({this.message = 'Something went wrong.', this.code});

  final String message;
  final String? code;

  /// Whether this failure should be reported to Crashlytics.
  /// Expected failures (validation, offline, quota) are not reported.
  bool get shouldReport => true;
}

/// No internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'You\'re offline. Check your connection.'})
      : super(code: 'NETWORK');
  @override
  bool get shouldReport => false;
}

/// Request timed out (AI 10–15s timeout).
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'This is taking too long. Please try again.'})
      : super(code: 'TIMEOUT');
  @override
  bool get shouldReport => false;
}

/// Generic API error from Cloud Functions / external service.
class ApiFailure extends Failure {
  const ApiFailure({super.message = 'Something went wrong on our end.', super.code = 'API', this.statusCode})
      : super();
  final int? statusCode;
  @override
  bool get shouldReport => true;
}

/// Firebase auth / firestore error.
class FirebaseFailure extends Failure {
  const FirebaseFailure({super.message = 'Authentication error. Please try again.', super.code = 'FIREBASE'})
      : super();
  @override
  bool get shouldReport => true;
}

/// Per-feature daily quota exceeded.
class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure({required this.feature, super.message})
      : super(code: 'QUOTA_EXCEEDED');
  final String feature;
  @override
  bool get shouldReport => false;
}

/// Global daily budget kill switch triggered.
class BudgetExceededFailure extends Failure {
  const BudgetExceededFailure({super.message = 'Daily limit reached. Please try tomorrow.'})
      : super(code: 'BUDGET_EXCEEDED');
  @override
  bool get shouldReport => false;
}

/// Rate limit: too many requests (1 req / 5–10s).
class RateLimitFailure extends Failure {
  const RateLimitFailure({super.message = 'Too many requests. Please wait a few seconds.'})
      : super(code: 'RATE_LIMIT');
  @override
  bool get shouldReport => false;
}

/// Input validation error with per-field messages.
class ValidationFailure extends Failure {
  const ValidationFailure({this.fieldErrors = const {}, super.message = 'Please fix the errors below.'})
      : super(code: 'VALIDATION');
  final Map<String, String> fieldErrors;
  @override
  bool get shouldReport => false;
}

/// Unknown / unexpected error.
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Something went wrong.', super.code = 'UNKNOWN'})
      : super();
  @override
  bool get shouldReport => true;
}

/// Request was cancelled.
class CancelledFailure extends Failure {
  const CancelledFailure({super.message = 'Request cancelled.', super.code = 'CANCELLED'})
      : super();
  @override
  bool get shouldReport => false;
}
