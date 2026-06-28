import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/common/app_button.dart';
import '../providers/auth_provider.dart';

/// Login screen: offers anonymous (continue) and Google sign-in.
/// Anonymous is the default frictionless path.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isBusy = false;

  Future<void> _continueAnonymously() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    await ref.read(authStateProvider.notifier).signInAnonymously();
    if (mounted) {
      setState(() => _isBusy = false);
      context.go(AppRoutes.home);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    await ref.read(authStateProvider.notifier).signInWithGoogle();
    if (mounted) {
      setState(() => _isBusy = false);
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  size: 64,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: AppSizes.lg),
              Text(
                'Welcome to ShortSEO AI',
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: AppSizes.sm),
              Text(
                'Generate viral titles, hashtags, descriptions, thumbnails, and more — powered by AI.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const Spacer(),
              AppButton(
                label: 'Get Started',
                icon: Icons.rocket_launch_rounded,
                isLoading: _isBusy,
                onPressed: _continueAnonymously,
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: AppSizes.md),
              AppButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                isLoading: _isBusy,
                variant: AppButtonVariant.outlined,
                onPressed: _signInWithGoogle,
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              const SizedBox(height: AppSizes.lg),
              Text(
                'By continuing you agree to our Terms and Privacy Policy.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}
