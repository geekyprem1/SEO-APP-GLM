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
  String _query = '';

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
    final q = _query.trim().toLowerCase();
    final sections = FeatureCatalog.bySection
        .map((e) => MapEntry(
              e.key,
              e.value
                  .map(_relabel)
                  .where((f) =>
                      q.isEmpty ||
                      f.title.toLowerCase().contains(q) ||
                      f.subtitle.toLowerCase().contains(q))
                  .toList(),
            ))
        .where((e) => e.value.isNotEmpty)
        .toList();

    final toolCount = FeatureCatalog.generators.length;

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
                color: AppColors.textPrimary,
                height: 1.1,
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: AppSizes.sm),
            Text(
              widget.subheading,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
            const SizedBox(height: AppSizes.md),
            // ── Chips ─────────────────────────────────────────
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                _Chip(label: '$toolCount AI Tools'),
                const _Chip(label: 'SEO Optimized'),
                const _Chip(label: 'Fast Generation'),
              ],
            ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
            const SizedBox(height: AppSizes.lg),
            // ── Search ────────────────────────────────────────
            _SearchBar(onChanged: (v) => setState(() => _query = v)),
            const SizedBox(height: AppSizes.lg),
            // ── Sections ──────────────────────────────────────
            if (sections.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.xl),
                child: Center(
                  child: Text(
                    'No tools match "$_query"',
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ...entry.value.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.sm + 4),
                          child: FeatureCard(
                            item: item,
                            onTap: () => _open(item),
                          ),
                        )),
                    const SizedBox(height: AppSizes.sm),
                  ]),
          ],
        ),
      ),
    );
  }
}

/// Subtle pill chip used in the hero.
class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded search field.
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textSecondary, size: 22),
          hintText: 'Search AI tools...',
          hintStyle: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
