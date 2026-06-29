import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import 'feature_item.dart';

/// Static catalog of home dashboard features, grouped into sections.
class FeatureCatalog {
  FeatureCatalog._();

  /// Section order on the dashboard.
  static const List<String> sectionOrder = ['Create', 'Grow', 'Content'];

  /// The 8 AI generation features shown in the Video/Short dashboard grids.
  static List<FeatureItem> get generators =>
      all.where((f) => f.id != 'history' && f.id != 'settings').toList();

  /// Generators grouped by section, in [sectionOrder].
  static List<MapEntry<String, List<FeatureItem>>> get bySection {
    return sectionOrder
        .map((s) => MapEntry(
              s,
              generators.where((f) => f.section == s).toList(),
            ))
        .where((e) => e.value.isNotEmpty)
        .toList();
  }

  static const List<FeatureItem> all = [
    // ── Create ──────────────────────────────────────────────
    FeatureItem(
      id: 'thumbnail',
      title: 'Thumbnail Generator',
      subtitle: 'AI thumbnail images',
      icon: Icons.image_outlined,
      color: AppColors.primary,
      route: AppRoutes.thumbnail,
      section: 'Create',
      gradient: [Color(0xFFFF9D4D), Color(0xFFF4621E)],
    ),
    FeatureItem(
      id: 'title',
      title: 'Title Generator',
      subtitle: '10 SEO-friendly titles',
      icon: Icons.title_rounded,
      color: AppColors.primary,
      route: AppRoutes.title,
      section: 'Create',
      gradient: [Color(0xFFFF6CAB), Color(0xFFD81B60)],
    ),
    FeatureItem(
      id: 'description',
      title: 'Description Generator',
      subtitle: 'SEO-optimized description',
      icon: Icons.notes_rounded,
      color: AppColors.primary,
      route: AppRoutes.description,
      section: 'Create',
      gradient: [Color(0xFF7C83FF), Color(0xFF4338CA)],
    ),
    FeatureItem(
      id: 'hashtags',
      title: 'Hashtag Generator',
      subtitle: '20 relevant hashtags',
      icon: Icons.tag_rounded,
      color: AppColors.primary,
      route: AppRoutes.hashtags,
      section: 'Create',
      gradient: [Color(0xFF34D399), Color(0xFF059669)],
    ),

    // ── Grow ────────────────────────────────────────────────
    FeatureItem(
      id: 'seo',
      title: 'SEO Analysis',
      subtitle: 'Analyze your Shorts',
      icon: Icons.insights_rounded,
      color: AppColors.primary,
      route: AppRoutes.seo,
      section: 'Grow',
      gradient: [Color(0xFF4F9DFF), Color(0xFF2563EB)],
    ),
    FeatureItem(
      id: 'trending',
      title: 'Trending Topics',
      subtitle: 'AI-powered trends',
      icon: Icons.trending_up_rounded,
      color: AppColors.primary,
      route: AppRoutes.trending,
      section: 'Grow',
      gradient: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
    ),

    // ── Content ─────────────────────────────────────────────
    FeatureItem(
      id: 'content',
      title: 'Script Generator',
      subtitle: 'Hook, content & CTA',
      icon: Icons.article_outlined,
      color: AppColors.primary,
      route: AppRoutes.content,
      section: 'Content',
      gradient: [Color(0xFFB06AF7), Color(0xFF7C3AED)],
    ),
    FeatureItem(
      id: 'viral_ideas',
      title: 'Viral Shorts Ideas',
      subtitle: '20 viral content ideas',
      icon: Icons.bolt_rounded,
      color: AppColors.primary,
      route: AppRoutes.viralIdeas,
      section: 'Content',
      gradient: [Color(0xFFFF5A5F), Color(0xFFE53935)],
    ),

    // ── Not shown in grid (accessed from Profile) ───────────
    FeatureItem(
      id: 'history',
      title: 'History',
      subtitle: 'Saved generations',
      icon: Icons.history_rounded,
      color: AppColors.primary,
      route: AppRoutes.history,
    ),
    FeatureItem(
      id: 'settings',
      title: 'Settings',
      subtitle: 'Theme & preferences',
      icon: Icons.settings_rounded,
      color: AppColors.primary,
      route: AppRoutes.settings,
    ),
  ];
}
