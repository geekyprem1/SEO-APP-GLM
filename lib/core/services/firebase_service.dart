import 'package:firebase_analytics/firebase_analytics.dart';
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
/// Config values come from the `short-seo-app` Firebase project
/// (mirrors android/app/google-services.json).
class FirebaseService {
  FirebaseService._();

  /// Initializes Firebase and returns the provider overrides.
  static Future<List<Override>> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBw-SStswOtuUMyIbm6_LsQUdjfLncYm3w',
        appId: '1:49047407805:android:7c0f8f5751698db91bfbd4',
        messagingSenderId: '49047407805',
        projectId: 'short-seo-app',
        storageBucket: 'short-seo-app.firebasestorage.app',
      ),
    );

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
