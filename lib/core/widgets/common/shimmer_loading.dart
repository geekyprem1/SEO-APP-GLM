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
    final scheme = Theme.of(context).colorScheme;
    // Theme-aware so the skeleton reads correctly in dark mode (the previous
    // hardcoded light-only colors washed out on dark surfaces).
    final baseColor = scheme.surfaceContainerHighest;
    final highlightColor = scheme.surfaceContainerHigh;

    return RepaintBoundary(
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        period: const Duration(milliseconds: 1400),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
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
    // Fixed-count Column rather than a nested shrinkWrap ListView: every row is
    // built anyway, and this skips the nested-scroll layout cost each frame.
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.sm),
            child: ShimmerLoading(
              height: itemHeight,
              borderRadius: AppSizes.radiusMd,
            ),
          ),
        ),
      ),
    );
  }
}
