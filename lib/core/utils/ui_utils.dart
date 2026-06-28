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

  /// Medium haptic feedback.
  static void mediumHaptic() => HapticFeedback.mediumImpact();

  /// Copy to clipboard with optional snackbar confirmation.
  static Future<void> copyToClipboard(
    BuildContext context,
    String text, {
    String? successMessage,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showSuccessSnackBar(context, successMessage ?? 'Copied to clipboard');
    }
  }
}
