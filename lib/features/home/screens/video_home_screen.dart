import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../widgets/feature_dashboard.dart';

/// Video tab dashboard — the 8 AI features in long-form (16:9) mode.
class VideoHomeScreen extends ConsumerWidget {
  const VideoHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FeatureDashboard(
      format: ContentFormat.longForm,
      heading: 'Tubora',
      subheading:
          'Create better YouTube content with AI. Generate thumbnails, titles, descriptions, scripts and viral ideas.',
    );
  }
}
