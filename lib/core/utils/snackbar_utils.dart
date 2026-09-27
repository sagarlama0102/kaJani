import 'package:flutter/material.dart';
import 'package:kajani/app/theme/app_colors.dart';

class SnackbarUtils {
  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      _friendlyMessage(message), //  sanitize technical errors
      accentColor: AppColors.error,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message, // success messages are already user-facing
      accentColor: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      accentColor: AppColors.primary,
      icon: Icons.info_outline_rounded,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      accentColor: const Color(0xFFFFA726),
      icon: Icons.warning_amber_rounded,
    );
  }

  // ─── Convert technical/backend errors into friendly user messages ──
  static String _friendlyMessage(String raw) {
    final lower = raw.toLowerCase();

    if (lower.contains('too many requests') || lower.contains('slow down')) {
      return "You're doing that too fast — please wait a moment and try again.";
    }
    if (lower.contains('socketexception') ||
        lower.contains('connection') ||
        lower.contains('failed host lookup') ||
        lower.contains('network') ||
        lower.contains('timeout') ||
        lower.contains('timed out')) {
      return "Couldn't connect. Please check your internet and try again.";
    }
    if (lower.contains('500') ||
        lower.contains('internal server') ||
        lower.contains('server error')) {
      return "Something went wrong on our end. Please try again in a bit.";
    }
    if (lower.contains('exception') || lower.contains('error:')) {
      // catches raw Dart exceptions that shouldn't reach the user
      return "Something went wrong. Please try again.";
    }

    // Otherwise it's a genuine user-facing message (e.g. "Invalid credentials",
    // "Username already in use") — show it as-is.
    return raw;
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color accentColor,
    required IconData icon,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      final isDark = Theme.of(context).brightness == Brightness.dark;

      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
          behavior: SnackBarBehavior.floating,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }
}