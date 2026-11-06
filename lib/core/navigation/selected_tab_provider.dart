import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the tab selected in the root shell.
///
/// Kept in a provider so any screen can switch to another tab — e.g. the
/// home dashboard's "Create my next video" primary action jumps straight
/// to the Create tab (AI Content Studio).
final selectedTabProvider =
    StateProvider<int>((ref) => AppTabIndex.create);

/// Tab order in the root shell: Video · Shorts · Create · Profile.
class AppTabIndex {
  AppTabIndex._();

  static const int video = 0;
  static const int shorts = 1;
  static const int create = 2;
  static const int profile = 3;
}
