import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../features/settings/providers/settings_provider.dart';

/// Tracks the user's consent for analytics + crash reporting and applies it to
/// Firebase. State is tri-valued:
///   null  → not asked yet (collection stays OFF until the user decides)
///   true  → allowed (collection ON)
///   false → declined (collection OFF)
///
/// Collection is opt-in: nothing is sent to Analytics/Crashlytics until the
/// user explicitly allows it, satisfying GDPR/CCPA + Play Data Safety.
class PrivacyConsentNotifier extends StateNotifier<bool?> {
  PrivacyConsentNotifier(this._box) : super(_box.get(storageKey) as bool?);

  final Box _box;

  /// Hive settings-box key holding the consent choice.
  static const String storageKey = 'analyticsConsent';

  /// True once the user has made a choice (used to show the consent prompt).
  bool get hasDecided => state != null;

  /// True only when the user has explicitly allowed collection.
  bool get isEnabled => state == true;

  /// Records the choice, persists it, and toggles Firebase collection live.
  Future<void> setConsent(bool enabled) async {
    state = enabled;
    await _box.put(storageKey, enabled);
    await applyToFirebase(enabled);
  }

  /// Applies an enabled/disabled choice to Firebase collection flags.
  /// Safe to call anytime; no-ops (and never throws) if Firebase is
  /// unavailable (e.g. the app's no-op fallback mode).
  static Future<void> applyToFirebase(bool enabled) async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(enabled);
    } catch (e) {
      if (kDebugMode) debugPrint('PrivacyConsent: applyToFirebase failed: $e');
    }
  }
}

/// Consent state: null = undecided, true = allowed, false = declined.
final privacyConsentProvider =
    StateNotifierProvider<PrivacyConsentNotifier, bool?>((ref) {
  return PrivacyConsentNotifier(ref.watch(settingsBoxProvider));
});
