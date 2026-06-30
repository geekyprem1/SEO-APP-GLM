import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../services/crashlytics_service.dart';
import '../error/error_handler.dart';

/// Provider for the [Logger].
///
/// In release builds logging is turned off entirely (`Level.off`) and the
/// heavy [PrettyPrinter] — which parses/box-draws stack traces on every call —
/// is swapped for the cheap [SimplePrinter], so no log work or string building
/// happens in production. Debug builds keep the readable pretty output.
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    level: kReleaseMode ? Level.off : Level.debug,
    printer: kReleaseMode
        ? SimplePrinter(printTime: false, colors: false)
        : PrettyPrinter(methodCount: 0, errorMethodCount: 5),
  );
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
