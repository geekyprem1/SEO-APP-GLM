import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/services/analytics_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/consent_gate.dart';
import 'features/auth/providers/auth_provider.dart';

/// Root widget for ShortSEO AI.
class ShortSeoApp extends ConsumerWidget {
  const ShortSeoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Sync analytics user id when auth changes.
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      next.whenData((user) {
        ref.read(analyticsServiceProvider).setUserId(user?.uid);
      });
    });

    return MaterialApp.router(
      title: 'Tubora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Premium light-first brand: lock to light until a designed dark theme
      // is added. (Avoids the system dark mode breaking the white surfaces.)
      themeMode: ThemeMode.light,
      routerConfig: router,
      // Overlay the one-time analytics/crash consent prompt on first launch.
      builder: (context, child) =>
          ConsentGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
