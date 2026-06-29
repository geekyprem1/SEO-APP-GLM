import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import 'analytics_service.dart';
import 'crashlytics_service.dart';
import 'ai/cloud_functions_ai_service.dart';
import 'ai/cloud_functions_image_service.dart';
import 'youtube/cloud_functions_youtube_service.dart';
import '../../features/auth/repository/auth_repository.dart';

/// Initializes Firebase and wires up all Firebase-backed providers.
///
/// On Android the native `google-services.json` (loaded by the
/// `com.google.gms.google-services` Gradle plugin) supplies the config, so we
/// initialize without inlining any keys into source — keeping config out of
/// version control.
class FirebaseService {
  FirebaseService._();

  /// Initializes Firebase and returns the provider overrides.
  static Future<List<Override>> initialize() async {
    await Firebase.initializeApp();

    // App Check: attest requests to the backend so off-device scripts can't
    // abuse the AI endpoints. Debug provider locally; Play Integrity in release.
    // (Enforcement is flipped on per-API in the Firebase App Check console.)
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      );
    } catch (_) {
      // Non-fatal: app still works while App Check is being configured.
    }

    // Crashlytics: record Flutter framework errors.
    final crashlytics = FirebaseCrashlytics.instance;
    FlutterError.onError = crashlytics.recordFlutterFatalError;
    // Pass all uncaught async errors to Crashlytics.
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    final auth = fb_auth.FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final functions = FirebaseFunctions.instance;
    final analytics = FirebaseAnalytics.instance;

    return [
      authRepositoryProvider.overrideWith(
        (ref) => AuthRepositoryImpl(
          auth,
          firestore,
          ref.watch(errorHandlerProvider),
        ),
      ),
      analyticsServiceProvider
          .overrideWith((ref) => AnalyticsServiceImpl(analytics)),
      crashlyticsServiceProvider
          .overrideWith((ref) => CrashlyticsServiceImpl(crashlytics)),
      aiServiceProvider.overrideWith(
        (ref) => CloudFunctionsAiService(functions, ref.watch(errorHandlerProvider)),
      ),
      imageGenerationServiceProvider.overrideWith(
        (ref) => CloudFunctionsImageService(functions, ref.watch(errorHandlerProvider)),
      ),
      youtubeServiceProvider.overrideWith(
        (ref) => CloudFunctionsYouTubeService(functions, ref.watch(errorHandlerProvider)),
      ),
    ];
  }
}
