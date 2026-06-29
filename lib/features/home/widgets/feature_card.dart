import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../models/feature_item.dart';

/// Premium gradient grid card: vibrant gradient background, white icon box,
/// white 2-line title. Presses to 0.97 with a soft colored shadow.
class FeatureCard extends StatefulWidget {
  const FeatureCard({super.key, required this.item, required this.onTap});

  final FeatureItem item;
  final VoidCallback onTap;

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final colors = item.gradient.length >= 2
        ? item.gradient
        : [item.color, item.color];

    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: _pressed ? 0.42 : 0.30),
                blurRadius: _pressed ? 22 : 16,
                offset: Offset(0, _pressed ? 10 : 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // White rounded icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(item.icon, size: 24, color: Colors.white),
              ),
              const Spacer(),
              const SizedBox(height: AppSizes.md),
              Text(
                item.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
