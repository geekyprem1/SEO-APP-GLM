import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../shared/models/content_format.dart';
import '../models/feature_catalog.dart';
import 'feature_card.dart';

/// Reusable dashboard grid of the 8 AI generation features.
///
/// Shared by the Video (long-form) and Short tabs. Tapping a feature records
/// the active [ContentFormat] before navigating, so each feature screen knows
/// which format to generate for.
class FeatureDashboard extends ConsumerWidget {
  const FeatureDashboard({
    super.key,
    required this.format,
    required this.heading,
    required this.subheading,
  });

  final ContentFormat format;
  final String heading;
  final String subheading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // For the long-form Video tab, relabel shorts-specific wording.
    final features = FeatureCatalog.generators.map((f) {
      if (format.isShorts) return f;
      return f.copyWith(
        title: f.title.replaceAll('Shorts', 'Video'),
        subtitle: f.subtitle.replaceAll('Shorts', 'Video'),
      );
    }).toList();

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
                      heading,
                      style: theme.textTheme.displayMedium,
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      subheading,
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
                    final item = features[index];
                    return FeatureCard(
                      item: item,
                      onTap: () {
                        // Record the active format, then open the feature.
                        ref.read(selectedFormatProvider.notifier).state = format;
                        context.push(item.route);
                      },
                    );
                  },
                  childCount: features.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.lg)),
          ],
        ),
      ),
    );
  }
}
