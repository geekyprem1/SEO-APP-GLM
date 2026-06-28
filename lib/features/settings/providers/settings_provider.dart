import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Persisted app settings.
class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system});
  final ThemeMode themeMode;

  AppSettings copyWith({ThemeMode? themeMode}) =>
      AppSettings(themeMode: themeMode ?? this.themeMode);
}

/// Notifier that manages app settings, persisted to Hive.
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._box) : super(const AppSettings()) {
    _load();
  }

  final Box _box;

  static const _themeModeKey = 'themeMode';

  void _load() {
    final index = _box.get(_themeModeKey) as int?;
    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      state = AppSettings(themeMode: ThemeMode.values[index]);
    }
  }

  /// Updates and persists the theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = AppSettings(themeMode: mode);
    await _box.put(_themeModeKey, mode.index);
  }
}

/// Provider for the Hive settings box.
/// Must be overridden in main.dart with an opened box.
final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('Override in main.dart with an opened Hive settings box.');
});

/// Provider for app settings.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsBoxProvider));
});

/// Convenience provider that exposes just the current ThemeMode.
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});
