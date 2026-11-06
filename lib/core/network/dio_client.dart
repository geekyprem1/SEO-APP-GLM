import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_constants.dart';

/// Dio singleton configured for ShortSEO AI.
/// Used for non-AI HTTP (oEmbed, image downloads).
/// AI calls go through Cloud Functions plugin (not Dio).
class DioClient {
  DioClient._();

  static Dio? _instance;

  /// Returns the configured Dio instance.
  static Dio get instance {
    _instance ??= _create();
    return _instance!;
  }

  /// Closes the singleton and clears it so the next access rebuilds a fresh
  /// client (used on teardown / in tests).
  static void close() {
    _instance?.close(force: true);
    _instance = null;
  }

  static Dio _create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: Duration(seconds: AppConstants.aiTimeoutSeconds),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(_RetryInterceptor(dio));

    // Dev-only logging. Request/response bodies are NOT logged — they can
    // contain signed image URLs and user content.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
        ),
      );
    }

    return dio;
  }
}

/// Retries idempotent GET requests a bounded number of times on transient
/// network failures. Non-idempotent methods are never retried, so a retry can
/// never duplicate a write.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  static const int _maxRetries = 2;

  final Dio _dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final retries = (options.extra['retryCount'] as int?) ?? 0;
    final isIdempotent = options.method.toUpperCase() == 'GET';
    final isTransient = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;

    if (!isIdempotent || !isTransient || retries >= _maxRetries) {
      return handler.next(err);
    }

    await Future<void>.delayed(Duration(milliseconds: 300 * (retries + 1)));
    options.extra['retryCount'] = retries + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }
}
