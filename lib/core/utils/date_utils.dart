import 'package:intl/intl.dart';

/// Date formatting utilities.
class DateUtils {
  DateUtils._();

  /// Formats a DateTime as a relative time (e.g. "2h ago", "Just now").
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Formats a DateTime as "MMM d, yyyy • HH:mm".
  static String formatFull(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • HH:mm').format(dateTime);
  }

  /// Today's date as "yyyy-MM-dd" (used as Firestore usage doc id).
  static String todayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
}
