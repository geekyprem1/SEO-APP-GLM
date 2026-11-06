import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Abstract share service interface.
abstract class ShareService {
  /// Shares [text]. [origin] anchors the iPad share popover (required there,
  /// harmless elsewhere) — callers pass their widget's bounds.
  Future<void> share(String text, {String? subject, Rect? origin});
}

/// share_plus implementation.
class ShareServiceImpl implements ShareService {
  @override
  Future<void> share(String text, {String? subject, Rect? origin}) async {
    await Share.share(
      text,
      subject: subject,
      sharePositionOrigin: origin,
    );
  }
}

/// Provider for [ShareService].
final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareServiceImpl();
});
