import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/consent_gate.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/settings/providers/settings_provider.dart';

/// Root widget for ShortSEO AI.
class ShortSeoApp extends ConsumerWidget {
  const ShortSeoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Sync analytics/crash user ids when auth changes. Sign-out clears the
    // identifier from both SDKs so a previous user's activity is never
    // attributed to the next session.
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      next.whenData((user) {
        ref.read(analyticsServiceProvider).setUserId(user?.uid);
        ref.read(crashlyticsServiceProvider).setUserId(user?.uid);
      });
    });

    return MaterialApp.router(
      title: 'Tubora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Follows the user's choice from Settings (System / Light / Dark),
      // persisted in Hive via settingsProvider.
      themeMode: themeMode,
      routerConfig: router,
      // Overlay the one-time analytics/crash consent prompt on first launch.
      builder: (context, child) =>
          ConsentGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
