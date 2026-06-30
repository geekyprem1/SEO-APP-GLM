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
  ///
  /// [analyticsConsent] reflects the user's stored choice (null = undecided).
  /// Collection is enabled ONLY when the user has explicitly allowed it, so
  /// nothing is sent to Analytics/Crashlytics before consent (opt-in).
  static Future<List<Override>> initialize({bool? analyticsConsent}) async {
    await Firebase.initializeApp();

    final collectionAllowed = analyticsConsent == true;

    // Crashlytics first so App Check activation failures can be reported.
    final crashlytics = FirebaseCrashlytics.instance;
    // Honour consent: no crash data leaves the device until the user opts in.
    await crashlytics.setCrashlyticsCollectionEnabled(collectionAllowed);
    FlutterError.onError = crashlytics.recordFlutterFatalError;
    // Pass all uncaught async errors to Crashlytics.
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    // App Check: attest requests to the backend so off-device scripts can't
    // abuse the AI endpoints. Play Integrity in release; debug provider locally.
    // (Enforcement is flipped on per-API in the Firebase App Check console.)
    //
    // Play Integrity ONLY succeeds for builds installed from Google Play. A
    // sideloaded release APK (direct install) cannot attest, which can stall
    // Firebase calls. For local release testing, disable via:
    //   flutter build apk --release --dart-define=ENABLE_APP_CHECK=false
    // The default is true, so Play Store / CI production builds keep App Check.
    const appCheckEnabled =
        bool.fromEnvironment('ENABLE_APP_CHECK', defaultValue: true);
    if (appCheckEnabled) {
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider:
              kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        );
        // Keep a fresh attestation token so backend enforcement doesn't reject
        // calls mid-session once App Check enforcement is enabled.
        await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
      } catch (e, st) {
        // Non-fatal so the app still launches, but DO surface it: a misconfigured
        // Play Integrity attestation must be visible, not silently disabled.
        await crashlytics.recordError(e, st, reason: 'AppCheck.activate failed');
      }
    }

    final auth = fb_auth.FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final functions = FirebaseFunctions.instance;
    final analytics = FirebaseAnalytics.instance;
    // Honour consent: analytics collection stays off until the user opts in.
    await analytics.setAnalyticsCollectionEnabled(collectionAllowed);

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
