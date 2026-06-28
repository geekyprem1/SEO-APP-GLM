import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

/// Central theme controller for ShortSEO AI.
class AppTheme {
  AppTheme._();

  static ThemeData get light => buildLightTheme();
  static ThemeData get dark => buildDarkTheme();

  /// Returns the theme for the given [ThemeMode].
  static ThemeData forMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => light,
      ThemeMode.dark => dark,
      ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
          ? dark
          : light,
    };
  }
}
