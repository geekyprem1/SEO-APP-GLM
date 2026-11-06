import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// UI helper utilities for spacing, snackbar, haptics.
class UiUtils {
  UiUtils._();

  /// Horizontal padding widget.
  static EdgeInsets get horizontalPadding => const EdgeInsets.symmetric(horizontal: 16);

  /// All-around padding.
  static EdgeInsets get screenPadding => const EdgeInsets.all(16);

  /// Shows a success snackbar.
  static void showSuccessSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Shows an error snackbar.
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Shows a snackbar with success/error styling.
  static void showSnackBar(BuildContext context, String message, {bool success = true}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Light haptic feedback.
  static void lightHaptic() => HapticFeedback.lightImpact();

  /// The share-popover anchor rect for the nearest render box.
  /// Required on iPad (UIKit needs a source rect) and ignored elsewhere.
  static Rect? shareOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Shows a snackbar with an Undo action.
  static void showUndoSnackBar(
    BuildContext context,
    String message, {
    required VoidCallback onUndo,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'Undo', onPressed: onUndo),
        ),
      );
  }

  /// Medium haptic feedback.
  static void mediumHaptic() => HapticFeedback.mediumImpact();

  /// Copy to clipboard with confirmation/error snackbars; never throws and
  /// never reports a copy that did not actually happen.
  static Future<void> copyToClipboard(
    BuildContext context,
    String text, {
    String? successMessage,
  }) async {
    if (text.trim().isEmpty) return;
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        showSuccessSnackBar(context, successMessage ?? 'Copied to clipboard');
      }
    } catch (_) {
      if (context.mounted) {
        showErrorSnackBar(context, 'Could not copy. Please try again.');
      }
    }
  }
}
