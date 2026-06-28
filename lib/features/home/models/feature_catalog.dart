import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../models/feature_item.dart';

/// Static catalog of home dashboard features.
/// Routes for not-yet-implemented features point to their planned paths;
/// the router will show a "coming soon" until each feature is built.
class FeatureCatalog {
  FeatureCatalog._();

  static const List<FeatureItem> all = [
    FeatureItem(
      id: 'title',
      title: 'Title Generator',
      subtitle: '10 SEO-friendly titles',
      icon: Icons.title_rounded,
      color: AppColors.titleAccent,
      route: AppRoutes.title,
    ),
    FeatureItem(
      id: 'hashtags',
      title: 'Hashtag Generator',
      subtitle: '20 relevant hashtags',
      icon: Icons.tag_rounded,
      color: AppColors.hashtagAccent,
      route: AppRoutes.hashtags,
    ),
    FeatureItem(
      id: 'description',
      title: 'Description Generator',
      subtitle: 'SEO-optimized description',
      icon: Icons.description_rounded,
      color: AppColors.descriptionAccent,
      route: AppRoutes.description,
    ),
    FeatureItem(
      id: 'content',
      title: 'Content Generator',
      subtitle: 'Hook, content & CTA',
      icon: Icons.article_rounded,
      color: AppColors.contentAccent,
      route: AppRoutes.content,
    ),
    FeatureItem(
      id: 'viral_ideas',
      title: 'Viral Shorts Ideas',
      subtitle: '20 viral content ideas',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.viralAccent,
      route: AppRoutes.viralIdeas,
    ),
    FeatureItem(
      id: 'trending',
      title: 'Trending Topics',
      subtitle: 'AI-powered trends',
      icon: Icons.trending_up_rounded,
      color: AppColors.trendingAccent,
      route: AppRoutes.trending,
    ),
    FeatureItem(
      id: 'thumbnail',
      title: 'Thumbnail Generator',
      subtitle: 'AI thumbnail images',
      icon: Icons.image_rounded,
      color: AppColors.thumbnailAccent,
      route: AppRoutes.thumbnail,
    ),
    FeatureItem(
      id: 'seo',
      title: 'SEO Analysis',
      subtitle: 'Analyze your Shorts',
      icon: Icons.analytics_rounded,
      color: AppColors.seoAccent,
      route: AppRoutes.seo,
    ),
    FeatureItem(
      id: 'history',
      title: 'History',
      subtitle: 'Saved generations',
      icon: Icons.history_rounded,
      color: AppColors.historyAccent,
      route: AppRoutes.history,
    ),
    FeatureItem(
      id: 'settings',
      title: 'Settings',
      subtitle: 'Theme & preferences',
      icon: Icons.settings_rounded,
      color: AppColors.settingsAccent,
      route: AppRoutes.settings,
    ),
  ];
}
