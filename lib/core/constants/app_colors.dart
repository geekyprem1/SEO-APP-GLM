import 'package:flutter/material.dart';

/// Centralized color palette for VideoSEO AI.
/// Minimal, premium light theme with a single red accent.
class AppColors {
  AppColors._();

  // Brand seed
  static const Color seed = Color(0xFFE53935);

  // Core palette (spec)
  static const Color primary = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFC62828);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFECECEC);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFF1F1F1);

  /// Light tint used behind icons (light red).
  static const Color primarySoft = Color(0xFFFDECEA);

  // Light scheme
  static const Color lightPrimary = primary;
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSurface = surface;
  static const Color lightBackground = background;

  // Dark scheme (kept minimal; app is light-first)
  static const Color darkPrimary = Color(0xFFFF6B6B);
  static const Color darkOnPrimary = Color(0xFF1A1110);
  static const Color darkSurface = Color(0xFF1A1718);
  static const Color darkBackground = Color(0xFF121011);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF6B7280);

  // Feature accents — all monochrome red per brand guidelines.
  static const Color titleAccent = primary;
  static const Color hashtagAccent = primary;
  static const Color descriptionAccent = primary;
  static const Color contentAccent = primary;
  static const Color viralAccent = primary;
  static const Color trendingAccent = primary;
  static const Color thumbnailAccent = primary;
  static const Color seoAccent = primary;
  static const Color historyAccent = primary;
  static const Color settingsAccent = primary;
}
