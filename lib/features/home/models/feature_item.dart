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
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  FeatureItem copyWith({String? title, String? subtitle}) {
    return FeatureItem(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon,
      color: color,
      route: route,
    );
  }
}
