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

    // Dev-only logging.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }

    return dio;
  }
}
