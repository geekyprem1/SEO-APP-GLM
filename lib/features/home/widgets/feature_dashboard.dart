import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/models/content_format.dart';
import '../models/feature_catalog.dart';
import '../models/feature_item.dart';
import 'feature_card.dart';
import 'plan_strip.dart';

/// Premium dashboard: hero + plan strip + grouped tool sections.
/// Shared by the Video (long-form) and Short tabs.
class FeatureDashboard extends ConsumerStatefulWidget {
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
  ConsumerState<FeatureDashboard> createState() => _FeatureDashboardState();
}

class _FeatureDashboardState extends ConsumerState<FeatureDashboard> {
  FeatureItem _relabel(FeatureItem f) {
    if (widget.format.isShorts) return f;

    // Copy that isn't just "Shorts" → "Video" (e.g. Hook's 3-second line).
    const videoSubtitles = <String, String>{
      'hook': 'Cold-open retention hooks',
      'captions': 'On-screen text overlays',
      'cta': 'End-screen & verbal CTAs',
    };

    return f.copyWith(
      title: f.title.replaceAll('Shorts', 'Video'),
      subtitle: videoSubtitles[f.id] ??
          f.subtitle.replaceAll('Shorts', 'Video'),
    );
  }

  void _open(FeatureItem item) {
    ref.read(selectedFormatProvider.notifier).state = widget.format;
    context.push(item.route);
  }

  @override
  Widget build(BuildContext context) {
    final sections = FeatureCatalog.bySection
        .map((e) => MapEntry(e.key, e.value.map(_relabel).toList()))
        .where((e) => e.value.isNotEmpty)
        .toList();

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.heroWash,
              AppColors.background,
            ],
            stops: [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.paddingLg,
              AppSizes.lg,
              AppSizes.paddingLg,
              AppSizes.xl,
            ),
            children: [
              Text(
                widget.heading,
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.1,
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: AppSizes.sm),
              Text(
                widget.subheading,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.45,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
              const SizedBox(height: AppSizes.md),
              const PlanStrip()
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 300.ms)
                  .slideY(begin: 0.08, end: 0),
              const SizedBox(height: AppSizes.lg),
              ...sections.expand((entry) => [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSizes.sm,
                        bottom: AppSizes.md,
                      ),
                      child: Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 160.ms, duration: 280.ms),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSizes.md,
                      crossAxisSpacing: AppSizes.md,
                      // Compact cards keep the icon, title and subtitle visually grouped.
                      childAspectRatio: 1.08,
                      children: entry.value
                          .map((item) => FeatureCard(
                                item: item,
                                onTap: () => _open(item),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppSizes.lg),
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
