import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/routes.dart';
import '../providers/auth_provider.dart';

/// Splash screen: shows branding → auto-signs-in anonymously → Home.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    // Failsafe: if auth doesn't resolve in 3 seconds, try to force a check
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_triggered) {
        final state = ref.read(authStateProvider);
        if (state is! AsyncLoading) {
          _handleAuth(state);
        } else {
          // If still loading, force anonymous sign in
          ref.read(authStateProvider.notifier).signInAnonymously();
        }
      }
    });
  }

  void _handleAuth(AuthState state) {
    if (_triggered || !mounted || state.isLoading || state.isRefreshing) return;

    state.when(
      data: (user) {
        if (user != null) {
          _triggered = true;
          context.go(AppRoutes.home);
        } else {
          // User is null (signed out), trigger anonymous sign-in.
          ref.read(authStateProvider.notifier).signInAnonymously();
        }
      },
      error: (error, stack) {
        // On error, try anonymous sign-in as a fallback.
        ref.read(authStateProvider.notifier).signInAnonymously();
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // React to auth state changes.
    ref.listen<AuthState>(authStateProvider, (_, next) => _handleAuth(next));

    // Also handle initial state if already resolved.
    if (authState is! AsyncLoading && !_triggered) {
      // Use post-frame to avoid calling context.go during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleAuth(authState);
      });
    }

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 64,
                color: AppColors.lightOnPrimary,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  duration: 800.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'ShortSEO AI - Booting...',
              style: theme.textTheme.displayMedium?.copyWith(
                color: AppColors.lightOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: AppSizes.sm),
            Text(
              'AI-Powered SEO for YouTube Shorts',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightOnPrimary.withValues(alpha: 0.8),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
            const SizedBox(height: AppSizes.xxl),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.lightOnPrimary.withValues(alpha: 0.7),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
