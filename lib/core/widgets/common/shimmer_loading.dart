import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/app_sizes.dart';

/// Shimmer skeleton placeholder for loading states.
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    this.height = 20,
    this.width,
    this.borderRadius = AppSizes.radiusSm,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
    final highlightColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A list of shimmer lines mimicking content loading.
class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 5, this.itemHeight = 60});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.sm),
        child: ShimmerLoading(
          height: itemHeight,
          borderRadius: AppSizes.radiusMd,
        ),
      ),
    );
  }
}
