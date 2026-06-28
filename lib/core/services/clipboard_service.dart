import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract clipboard service interface.
abstract class ClipboardService {
  Future<void> copy(String text);
}

/// Flutter Clipboard implementation.
class ClipboardServiceImpl implements ClipboardService {
  @override
  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}

/// Provider for [ClipboardService].
final clipboardServiceProvider = Provider<ClipboardService>((ref) {
  return ClipboardServiceImpl();
});
