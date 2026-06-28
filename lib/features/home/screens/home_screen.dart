import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../models/feature_catalog.dart';
import '../widgets/feature_card.dart';

/// Home dashboard: grid of feature cards.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingLg,
                AppSizes.paddingLg,
                AppSizes.paddingLg,
                AppSizes.paddingSm,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ShortSEO AI',
                      style: theme.textTheme.displayMedium,
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Create viral YouTube Shorts content with AI',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLg,
                vertical: AppSizes.paddingSm,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSizes.md,
                  crossAxisSpacing: AppSizes.md,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = FeatureCatalog.all[index];
                    return FeatureCard(
                      item: item,
                      onTap: () => _onFeatureTap(context, item.route),
                    );
                  },
                  childCount: FeatureCatalog.all.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),
          ],
        ),
      ),
    );
  }

  void _onFeatureTap(BuildContext context, String route) {
    // Routes not yet registered will be caught by the router error builder,
    // which shows a friendly "coming soon" message.
    context.push(route);
  }
}
