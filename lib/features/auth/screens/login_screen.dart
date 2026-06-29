import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/error/failures.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/widgets/common/app_button.dart';
import '../../../core/widgets/common/app_text_field.dart';
import '../providers/auth_provider.dart';

/// Login screen: Email/Password, Google, and Skip (anonymous).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isBusy = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Runs an auth action, then routes home on success or shows the error.
  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    await action();
    if (!mounted) return;
    setState(() => _isBusy = false);

    final state = ref.read(authStateProvider);
    state.when(
      data: (user) {
        if (user != null) context.go(AppRoutes.home);
      },
      error: (error, _) {
        final msg = error is Failure ? error.message : 'Something went wrong.';
        UiUtils.showErrorSnackBar(context, msg);
      },
      loading: () {},
    );
  }

  Future<void> _submitEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    await _run(() => _isSignUp
        ? ref.read(authStateProvider.notifier).signUpWithEmail(email: email, password: password)
        : ref.read(authStateProvider.notifier).signInWithEmail(email: email, password: password));
  }

  Future<void> _google() =>
      _run(() => ref.read(authStateProvider.notifier).signInWithGoogle());

  Future<void> _skip() =>
      _run(() => ref.read(authStateProvider.notifier).signInAnonymously());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.xxl),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.bolt_rounded, size: 56,
                        color: theme.colorScheme.onPrimaryContainer),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  _isSignUp ? 'Create your account' : 'Welcome back',
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Tubora — viral content, powered by AI',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.xl),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Email is required';
                    if (!t.contains('@') || !t.contains('.')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'At least 6 characters',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if ((v ?? '').length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                AppButton(
                  label: _isSignUp ? 'Sign up' : 'Sign in',
                  icon: Icons.email_rounded,
                  isLoading: _isBusy,
                  onPressed: _submitEmail,
                ),
                const SizedBox(height: AppSizes.sm),
                TextButton(
                  onPressed: _isBusy ? null : () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp
                      ? 'Already have an account? Sign in'
                      : "Don't have an account? Sign up"),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                      child: Text('OR', style: theme.textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                AppButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  variant: AppButtonVariant.outlined,
                  isLoading: _isBusy,
                  onPressed: _google,
                ),
                const SizedBox(height: AppSizes.sm),
                AppButton(
                  label: 'Skip — continue as Guest',
                  variant: AppButtonVariant.text,
                  isLoading: _isBusy,
                  onPressed: _skip,
                ),
                const SizedBox(height: AppSizes.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
