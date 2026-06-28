import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/history_item.dart';

/// UI metadata for a [HistoryType]: icon, color, and label.
class HistoryTypeMeta {
  const HistoryTypeMeta._(this.icon, this.color, this.label);

  final IconData icon;
  final Color color;
  final String label;

  static HistoryTypeMeta forType(HistoryType type) {
    return switch (type) {
      HistoryType.title => const HistoryTypeMeta._(
          Icons.title_rounded, AppColors.titleAccent, 'Title'),
      HistoryType.hashtag => const HistoryTypeMeta._(
          Icons.tag_rounded, AppColors.hashtagAccent, 'Hashtag'),
      HistoryType.description => const HistoryTypeMeta._(
          Icons.description_rounded, AppColors.descriptionAccent, 'Description'),
      HistoryType.content => const HistoryTypeMeta._(
          Icons.article_rounded, AppColors.contentAccent, 'Content'),
      HistoryType.viralIdeas => const HistoryTypeMeta._(
          Icons.local_fire_department_rounded, AppColors.viralAccent, 'Viral Ideas'),
      HistoryType.trending => const HistoryTypeMeta._(
          Icons.trending_up_rounded, AppColors.trendingAccent, 'Trending'),
      HistoryType.thumbnail => const HistoryTypeMeta._(
          Icons.image_rounded, AppColors.thumbnailAccent, 'Thumbnail'),
      HistoryType.seo => const HistoryTypeMeta._(
          Icons.analytics_rounded, AppColors.seoAccent, 'SEO Analysis'),
    };
  }
}
