import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Splash screen: branding while the router resolves the session.
///
/// Intentionally passive — navigation is owned by the router (and by the login
/// screen after an explicit sign-in), so this screen never issues `go()` calls.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              'Tubora',
              style: theme.textTheme.displayMedium?.copyWith(
                color: AppColors.lightOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: AppSizes.sm),
            Text(
              'AI-Powered SEO for YouTube',
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
