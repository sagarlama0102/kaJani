import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand Colors ─────────────────────────────────────────────
  static const Color primary = Color(0xff7C3AED);        // Purple
  static const Color primaryDark = Color(0xff6D28D9);    // Darker purple
  static const Color primaryLight = Color(0xffA78BFA);   // Light purple

  // ─── Auth Colors ──────────────────────────────────────────────
  static const Color authPrimary = Color(0xff7C3AED);    // Login button (keep your existing)

  // ─── Background Colors ────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);     // Light bg
  static const Color darkBackground = Color(0xff0F0F0F); // True dark bg
  static const Color darkSurface = Color(0xff1A1A1A);    // Dark card/surface
  static const Color darkSurfaceVariant = Color(0xff242424); // Elevated surface

  // ─── Input ────────────────────────────────────────────────────
  static const Color inputFill = Color(0xFFF5F5F5);
  static const Color darkInputFill = Color(0xff1F1F1F);

  // ─── Text Colors ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextTertiary = Color(0xFF6B7280);

  // ─── Border & Divider ─────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkDivider = Color(0xFF2A2A2A);

  // ─── Status Colors ────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── White Opacity ────────────────────────────────────────────
  static const Color white90 = Color(0xE6FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color black20 = Color(0x33000000);

  // ─── Gradients ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xff7C3AED), Color(0xff6D28D9)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xff0F0F0F), Color(0xff1A1A1A)],
  );

  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xAA000000), Color(0xDD000000)],
  );

  // ─── Shadows ──────────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x147C3AED),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> darkSoftShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x407C3AED),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}