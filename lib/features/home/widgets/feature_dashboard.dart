import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../shared/models/content_format.dart';
import '../models/feature_catalog.dart';
import '../models/feature_item.dart';
import 'feature_card.dart';

/// Premium dashboard: hero + chips + search + grouped tool sections.
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
    return f.copyWith(
      title: f.title.replaceAll('Shorts', 'Video'),
      subtitle: f.subtitle.replaceAll('Shorts', 'Video'),
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
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.paddingLg,
            AppSizes.lg,
            AppSizes.paddingLg,
            AppSizes.xl,
          ),
          children: [
            // ── Hero ──────────────────────────────────────────
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
            const SizedBox(height: AppSizes.lg),
            // ── Sections ──────────────────────────────────────
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
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSizes.md,
                      crossAxisSpacing: AppSizes.md,
                      childAspectRatio: 1.1,
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
    );
  }
}

