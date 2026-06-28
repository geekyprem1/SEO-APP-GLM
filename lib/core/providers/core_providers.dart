import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../services/crashlytics_service.dart';
import '../error/error_handler.dart';

/// Provider for the [Logger].
final loggerProvider = Provider<Logger>((ref) {
  return Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5));
});

/// Provider for the [ErrorHandler], wired to Crashlytics.
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  final crashlytics = ref.watch(crashlyticsServiceProvider);
  return ErrorHandler(
    recordCrashlytics: (error, stack, {String? reason}) {
      crashlytics.recordError(error, stack, reason: reason);
    },
  );
});
