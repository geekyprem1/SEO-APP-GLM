import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/config/app_constants.dart';
import 'core/providers/core_providers.dart';
import 'core/services/privacy_consent.dart';
import 'core/storage/hive_encryption.dart';
import 'core/services/ai/ai_service.dart';
import 'core/services/ai/cloud_functions_ai_service.dart';
import 'core/services/ai/image_generation_service.dart';
import 'core/services/ai/cloud_functions_image_service.dart';
import 'core/services/ai/models.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/youtube/cloud_functions_youtube_service.dart';
import 'core/services/youtube/youtube_models.dart';
import 'core/services/youtube/youtube_service.dart';
import 'features/auth/models/auth_user.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/history/models/history_item.dart';
import 'features/history/repository/history_repository.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local storage.
  await Hive.initFlutter();
  Hive.registerAdapter(HistoryTypeAdapter());
  Hive.registerAdapter(HistoryItemAdapter());

  // Encrypt every box at rest with an AES key held in the platform secure
  // store. migrateIfNeeded() converts any pre-existing plaintext boxes from
  // older builds before we open them encrypted, so no user data is lost.
  final hiveEnc = HiveEncryption.instance;
  await hiveEnc.migrateIfNeeded(
    const [AppConstants.historyBox, AppConstants.settingsBox],
  );
  final cipher = await hiveEnc.cipher();

  final historyBox = await Hive.openBox<HistoryItem>(
    AppConstants.historyBox,
    encryptionCipher: cipher,
  );
  final settingsBox = await Hive.openBox(
    AppConstants.settingsBox,
    encryptionCipher: cipher,
  );

  // Read the stored analytics/crash-reporting consent (null = not asked yet)
  // so Firebase starts with collection in the user's chosen state.
  final analyticsConsent =
      settingsBox.get(PrivacyConsentNotifier.storageKey) as bool?;

  // Initialize Firebase and get overrides.
  List<Override> overrides;
  try {
    overrides = await FirebaseService.initialize(
      analyticsConsent: analyticsConsent,
    );
  } catch (e) {
    // debugPrint still writes to logcat in release; guard it so init details
    // never leak in production builds.
    if (kDebugMode) {
      debugPrint('Firebase initialization failed: $e — using no-op overrides.');
    }
    overrides = _noOpOverrides();
  }

  // Add Hive overrides.
  overrides = [
    ...overrides,
    historyRepositoryProvider.overrideWith(
      (ref) => HistoryRepositoryImpl(historyBox, ref.watch(errorHandlerProvider)),
    ),
    settingsBoxProvider.overrideWithValue(settingsBox),
  ];

  runApp(
    ProviderScope(overrides: overrides, child: const ShortSeoApp()),
  );
}

/// No-op overrides when Firebase is unavailable.
/// Allows the app to render UI even without a real Firebase config.
List<Override> _noOpOverrides() {
  final fakeUser = AuthUser(
    uid: 'noop-user',
    isAnonymous: true,
    createdAt: DateTime.now(),
  );

  return [
    authRepositoryProvider.overrideWith((ref) => _NoOpAuthRepository(fakeUser)),
    analyticsServiceProvider.overrideWith((ref) => _NoOpAnalytics()),
    crashlyticsServiceProvider.overrideWith((ref) => _NoOpCrashlytics()),
    aiServiceProvider.overrideWith((ref) => _NoOpAiService()),
    imageGenerationServiceProvider.overrideWith((ref) => _NoOpImageService()),
    youtubeServiceProvider.overrideWith((ref) => _NoOpYouTubeService()),
  ];
}

// ─── No-op implementations ──────────────────────────────────────────────

class _NoOpAuthRepository implements AuthRepository {
  _NoOpAuthRepository(this._user);
  final AuthUser _user;

  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(_user);

  @override
  Future<AuthUser> signInAnonymously() async => _user;

  @override
  Future<AuthUser> signInWithGoogle() async => _user;

  @override
  Future<AuthUser> signInWithEmail({required String email, required String password}) async => _user;

  @override
  Future<AuthUser> signUpWithEmail({required String email, required String password}) async => _user;

  @override
  Future<void> signOut() async {}

  @override
  AuthUser? get currentUser => _user;
}

class _NoOpAnalytics implements AnalyticsService {
  @override
  Future<void> logEvent({required String name, Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreenView({required String screenName}) async {}

  @override
  Future<void> setUserId(String? uid) async {}
}

class _NoOpCrashlytics implements CrashlyticsService {
  @override
  Future<void> recordError(Object error, StackTrace stack, {String? reason}) async {}

  @override
  Future<void> setUserId(String? uid) async {}

  @override
  Future<void> log(String message) async {}
}

class _NoOpAiService implements AiService {
  @override
  Future<AiResult> generate({required AiRequest request}) async {
    throw UnimplementedError('AI service unavailable — Firebase not configured.');
  }
}

class _NoOpImageService implements ImageGenerationService {
  @override
  Future<ImageResult> generateImage({required ImageRequest request}) async {
    throw UnimplementedError('Image service unavailable — Firebase not configured.');
  }
}

class _NoOpYouTubeService implements YouTubeService {
  @override
  Future<YouTubeVideo> fetchVideoMetadata({required String videoUrlOrId}) async {
    throw UnimplementedError('YouTube service unavailable — Firebase not configured.');
  }

  @override
  Future<YouTubeChannel> fetchChannelInfo({required String channelId}) async {
    throw UnimplementedError('YouTube service unavailable — Firebase not configured.');
  }

  @override
  Future<List<YouTubeSearchResult>> search({required String query, int maxResults = 10}) async {
    throw UnimplementedError('YouTube service unavailable — Firebase not configured.');
  }
}
