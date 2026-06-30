import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_constants.dart';
import '../../error/error_handler.dart';
import '../../error/exceptions.dart';
import 'models.dart';
import 'image_generation_service.dart';

/// Cloud Functions implementation of [ImageGenerationService].
///
/// Calls the `generateImage` callable Cloud Function which:
/// 1. Verifies Firebase ID token
/// 2. Checks rate limit
/// 3. Checks thumbnail daily quota (3/day)
/// 4. Checks budget kill switch
/// 5. Checks cache
/// 6. Calls Replicate (FLUX.1 Schnell) with server-side API key
/// 7. Logs request
/// 8. Increments usage counter
/// 9. Returns image URL
class CloudFunctionsImageService implements ImageGenerationService {
  CloudFunctionsImageService(this._functions, this._errorHandler);

  final FirebaseFunctions _functions;
  final ErrorHandler _errorHandler;

  @override
  Future<ImageResult> generateImage({required ImageRequest request}) async {
    try {
    final callable = _functions.httpsCallable(AppConstants.generateImageFunction);
      // NOTE: no cacheKey is sent — the server derives a uid-namespaced
      // SHA-256 cache key itself. Client-supplied keys are never trusted.
      final response = await callable.call<dynamic>({
        'feature': request.feature.id,
        'prompt': request.prompt,
        'width': request.width,
        'height': request.height,
      });

      final data = jsonDecode(jsonEncode(response.data)) as Map<String, dynamic>;

      final error = data['error'] as String?;
      if (error != null) {
        final code = data['errorCode'] as String? ?? 'UNKNOWN';
        switch (code) {
          case 'QUOTA_EXCEEDED':
            throw QuotaExceededException(request.feature.id);
          case 'BUDGET_EXCEEDED':
            throw BudgetExceededException(error);
          case 'RATE_LIMIT':
            throw RateLimitException(error);
          default:
            throw ApiException(error, code: code);
        }
      }

      return ImageResult(
        imageUrl: data['imageUrl'] as String,
        width: data['width'] as int? ?? request.width,
        height: data['height'] as int? ?? request.height,
        estimatedCost: (data['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

/// Provider for [ImageGenerationService].
final imageGenerationServiceProvider = Provider<ImageGenerationService>((ref) {
  throw UnimplementedError('Override in main.dart with CloudFunctionsImageService.');
});
