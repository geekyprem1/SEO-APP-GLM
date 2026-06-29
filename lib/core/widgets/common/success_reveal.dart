import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a freshly generated result: fires a light haptic on first appearance
/// and reveals the child with a subtle scale + fade.
class SuccessReveal extends StatefulWidget {
  const SuccessReveal({super.key, required this.child});

  final Widget child;

  @override
  State<SuccessReveal> createState() => _SuccessRevealState();
}

class _SuccessRevealState extends State<SuccessReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final scale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(scale: scale, child: widget.child),
    );
  }
}
