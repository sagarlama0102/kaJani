import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand Colors ─────────────────────────────────────────────

  static const Color primary = Color(0xFF3F61D2);
  static const Color primaryDark = Color(0xFF2863EC);
  static const Color primaryLight = Color(0xFF4974FF);

  // ─── Background Colors ────────────────────────────────────────

  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF242424);

  // ─── Input Colors ─────────────────────────────────────────────

  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color darkInputFill = Color(0xFF1F1F1F);

  // ─── Skeleton / Shimmer ───────────────────────────────────────

  static const Color skeletonBase = Color(0xFFE8E9EC);
  static const Color skeletonHighlight = Color(0xFFF5F6F8);

  static const Color darkSkeletonBase = Color(0xFF2A2A2A);
  static const Color darkSkeletonHighlight = Color(0xFF3A3A3A);

  // ─── Text Colors ──────────────────────────────────────────────

  static const Color textPrimary = Color(0xFF111827);
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

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // ─── UI States ────────────────────────────────────────────────

  static const Color disabled = Color(0xFFE5E7EB);
  static const Color disabledText = Color(0xFF9CA3AF);

  static const Color overlay = Color(0x52000000);

  // ─── White / Black Opacity ────────────────────────────────────

  static const Color white90 = Color(0xE6FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);

  static const Color black20 = Color(0x33000000);

  // ─── Gradients ────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2863EC), Color(0xFF4974FF)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A)],
  );

  // ─── Shadows ──────────────────────────────────────────────────

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 6)),
  ];

  static const List<BoxShadow> darkCardShadow = [
    BoxShadow(color: Color(0x26000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> darkSoftShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(color: Color(0x302863EC), blurRadius: 14, offset: Offset(0, 4)),
  ];
}
