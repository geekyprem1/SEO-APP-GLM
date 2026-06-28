/// Custom exception types for internal use.
/// These are caught at the repository/service boundary and converted to [Failure]s.
class AppException implements Exception {
  AppException(this.message, {this.code, this.cause});
  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  NetworkException([String message = 'No internet connection.']) : super(message, code: 'NETWORK');
}

class TimeoutException extends AppException {
  TimeoutException([String message = 'Request timed out.']) : super(message, code: 'TIMEOUT');
}

class ApiException extends AppException {
  ApiException(super.message, {this.statusCode, super.code = 'API'});
  final int? statusCode;
}

class FirebaseException extends AppException {
  FirebaseException(super.message, {super.code = 'FIREBASE'});
}

class QuotaExceededException extends AppException {
  QuotaExceededException(this.feature) : super('Daily limit for $feature reached.', code: 'QUOTA_EXCEEDED');
  final String feature;
}

class BudgetExceededException extends AppException {
  BudgetExceededException([String message = 'Daily limit reached.']) : super(message, code: 'BUDGET_EXCEEDED');
}

class RateLimitException extends AppException {
  RateLimitException([String message = 'Too many requests.']) : super(message, code: 'RATE_LIMIT');
}

class ValidationException extends AppException {
  ValidationException(this.fieldErrors) : super('Validation failed.', code: 'VALIDATION');
  final Map<String, String> fieldErrors;
}
