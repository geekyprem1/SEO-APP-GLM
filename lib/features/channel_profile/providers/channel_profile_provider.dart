import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../settings/providers/settings_provider.dart';
import '../models/channel_profile.dart';

/// Manages the creator's saved [ChannelProfile], persisted to the Hive
/// settings box so it survives restarts and is available to every generator.
class ChannelProfileNotifier extends StateNotifier<ChannelProfile> {
  ChannelProfileNotifier(this._box) : super(const ChannelProfile()) {
    _load();
  }

  final Box _box;

  static const _storageKey = 'channelProfile';

  void _load() {
    final stored = _box.get(_storageKey);
    if (stored is Map) {
      state = channelProfileFromStorageMap(stored);
    }
  }

  /// Persists [profile] and updates the state.
  Future<void> save(ChannelProfile profile) async {
    state = profile;
    await _box.put(_storageKey, profile.toStorageMap());
  }

  /// Clears the stored profile.
  Future<void> clear() async {
    state = const ChannelProfile();
    await _box.delete(_storageKey);
  }
}

/// Provider for the creator's channel profile.
///
/// Backed by the same Hive box that [settingsProvider] uses (overridden in
/// main.dart), so no extra overrides are needed.
final channelProfileProvider =
    StateNotifierProvider<ChannelProfileNotifier, ChannelProfile>((ref) {
  return ChannelProfileNotifier(ref.watch(settingsBoxProvider));
});
