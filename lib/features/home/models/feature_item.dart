import 'package:flutter/material.dart';

/// A feature entry on the home dashboard.
class FeatureItem {
  const FeatureItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    this.section = 'Create',
    this.gradient = const [Color(0xFFFF5A5F), Color(0xFFE53935)],
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  /// Group heading on the dashboard (Create / Grow / Content).
  final String section;

  /// Two-stop gradient for the premium card background.
  final List<Color> gradient;

  FeatureItem copyWith({String? title, String? subtitle}) {
    return FeatureItem(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon,
      color: color,
      route: route,
      section: section,
      gradient: gradient,
    );
  }
}
