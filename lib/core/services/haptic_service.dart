import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract haptic feedback service interface.
abstract class HapticService {
  Future<void> light();
  Future<void> medium();
  Future<void> heavy();
  Future<void> selection();
}

/// Flutter HapticFeedback implementation.
class HapticServiceImpl implements HapticService {
  @override
  Future<void> light() => HapticFeedback.lightImpact();

  @override
  Future<void> medium() => HapticFeedback.mediumImpact();

  @override
  Future<void> heavy() => HapticFeedback.heavyImpact();

  @override
  Future<void> selection() => HapticFeedback.selectionClick();
}

/// Provider for [HapticService].
final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticServiceImpl();
});
