import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

/// Abstract share service interface.
abstract class ShareService {
  Future<void> share(String text, {String? subject});
}

/// share_plus implementation.
class ShareServiceImpl implements ShareService {
  @override
  Future<void> share(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }
}

/// Provider for [ShareService].
final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareServiceImpl();
});
