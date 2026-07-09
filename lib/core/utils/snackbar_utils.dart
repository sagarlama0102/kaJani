import 'package:flutter/material.dart';
import 'package:kajani/app/theme/app_colors.dart';

class SnackbarUtils {
  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      accentColor: AppColors.error,
      icon: Icons.error_outline_rounded,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
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

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color accentColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars(); // avoid stacking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // ─── Accent icon container ──────────────────────────
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            // ─── Message ────────────────────────────────────────
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xff1A1A2E), // matches app surface
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: accentColor.withOpacity(0.3), // subtle accent border
            width: 1,
          ),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}