import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/router/routes.dart';
import '../../auth/providers/auth_provider.dart';

/// Profile tab — user info plus access to History, Settings, and sign out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).valueOrNull;

    final isGuest = user?.isAnonymous ?? true;
    final name = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (isGuest ? 'Guest user' : (user?.email ?? 'User'));
    final subtitle = isGuest ? 'Signed in anonymously' : (user?.email ?? '');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          children: [
            Text('Profile', style: theme.textTheme.displaySmall),
            const SizedBox(height: AppSizes.lg),
            // User header
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: (user?.photoUrl != null)
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: (user?.photoUrl == null)
                      ? Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: theme.textTheme.titleMedium),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),
            // Menu
            _ProfileTile(
              icon: Icons.history_rounded,
              title: 'History',
              subtitle: 'Your saved generations',
              onTap: () => context.push(AppRoutes.history),
            ),
            const SizedBox(height: AppSizes.sm),
            _ProfileTile(
              icon: Icons.settings_rounded,
              title: 'Settings',
              subtitle: 'Theme & preferences',
              onTap: () => context.push(AppRoutes.settings),
            ),
            const SizedBox(height: AppSizes.xl),
            // Auth action
            if (isGuest)
              FilledButton.icon(
                onPressed: () => ref.read(authStateProvider.notifier).signInWithGoogle(),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Sign in with Google'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => ref.read(authStateProvider.notifier).signOut(),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
