import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_constants.dart';
import '../../error/error_handler.dart';
import '../../error/exceptions.dart';
import 'models.dart';
import 'ai_service.dart';

/// Cloud Functions implementation of [AiService].
///
/// Calls the `generateContent` callable Cloud Function which:
/// 1. Verifies Firebase ID token
/// 2. Checks rate limit (1 req / 5–10s)
/// 3. Checks per-feature daily quota
/// 4. Checks budget kill switch
/// 5. Checks cache
/// 6. Calls OpenRouter (Gemini 2.5 Flash) with server-side API key
/// 7. Logs request (uid, feature, model, tokens, cost, time)
/// 8. Increments usage counters
/// 9. Returns JSON result
class CloudFunctionsAiService implements AiService {
  CloudFunctionsAiService(this._functions, this._errorHandler);

  final FirebaseFunctions _functions;
  final ErrorHandler _errorHandler;

  @override
  Future<AiResult> generate({required AiRequest request}) async {
    try {
    final callable = _functions.httpsCallable(AppConstants.generateContentFunction);
      final response = await callable.call<dynamic>({
        'feature': request.feature.id,
        'prompt': request.prompt,
        'schema': request.schema,
        'maxTokens': request.maxTokens,
        'temperature': request.temperature,
        'cacheKey': request.cacheKey,
      });

      // cloud_functions returns nested maps as Map<Object?, Object?> on
      // Android/iOS. Round-trip through JSON to normalize to Map<String, dynamic>.
      final data = jsonDecode(jsonEncode(response.data)) as Map<String, dynamic>;

      // Check for server-side quota/budget/rate-limit signals.
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

      return AiResult(
        rawText: data['rawText'] as String? ?? '',
        json: data['json'] as Map<String, dynamic>?,
        tokensUsed: data['tokensUsed'] as int? ?? 0,
        estimatedCost: (data['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e, st) {
      throw _errorHandler.convert(e, st);
    }
  }
}

/// Provider for [AiService].
/// Override in main.dart with [CloudFunctionsAiService] once Firebase is init.
final aiServiceProvider = Provider<AiService>((ref) {
  throw UnimplementedError('Override in main.dart with CloudFunctionsAiService.');
});
