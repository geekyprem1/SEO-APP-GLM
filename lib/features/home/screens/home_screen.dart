import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/content_format.dart';
import '../widgets/feature_dashboard.dart';

/// Short tab dashboard — the 8 AI features in Shorts (vertical) mode.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FeatureDashboard(
      format: ContentFormat.shorts,
      heading: 'Tubora',
      subheading:
          'Create viral YouTube Shorts with AI. Generate thumbnails, titles, hashtags, scripts and viral ideas.',
    );
  }
}
