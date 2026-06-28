import 'package:flutter/material.dart';

/// Centralized color palette for ShortSEO AI.
/// Uses a branded indigo/violet seed for a modern, premium look.
class AppColors {
  AppColors._();

  // Brand seed color (indigo-violet)
  static const Color seed = Color(0xFF6366F1);

  // Light scheme derived colors
  static const Color lightPrimary = Color(0xFF4F46E5);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFAFAFF);
  static const Color lightBackground = Color(0xFFF5F5FA);

  // Dark scheme derived colors
  static const Color darkPrimary = Color(0xFF818CF8);
  static const Color darkOnPrimary = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkBackground = Color(0xFF0F0F1A);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Feature accent colors (for home cards)
  static const Color titleAccent = Color(0xFF6366F1);
  static const Color hashtagAccent = Color(0xFFEC4899);
  static const Color descriptionAccent = Color(0xFFF59E0B);
  static const Color contentAccent = Color(0xFF10B981);
  static const Color viralAccent = Color(0xFF8B5CF6);
  static const Color trendingAccent = Color(0xFFEF4444);
  static const Color thumbnailAccent = Color(0xFF06B6D4);
  static const Color seoAccent = Color(0xFF3B82F6);
  static const Color historyAccent = Color(0xFF64748B);
  static const Color settingsAccent = Color(0xFF6B7280);
}
