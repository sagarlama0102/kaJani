import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeColorsExtension on BuildContext {
  // ─── Theme Mode ────────────────────────────────────────────────

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ─── Brand Colors ─────────────────────────────────────────────

  Color get primary => AppColors.primary;

  Color get primaryDark => AppColors.primaryDark;

  Color get primaryLight => AppColors.primaryLight;

  LinearGradient get primaryGradient => AppColors.primaryGradient;

  // ─── Skeleton / Shimmer ───────────────────────────────────────

  Color get skeletonBaseColor =>
      isDarkMode ? AppColors.darkSkeletonBase : AppColors.skeletonBase;

  Color get skeletonHighlightColor => isDarkMode
      ? AppColors.darkSkeletonHighlight
      : AppColors.skeletonHighlight;

  // ─── Text Colors ──────────────────────────────────────────────

  Color get textPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;

  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

  Color get textTertiary =>
      isDarkMode ? AppColors.darkTextTertiary : AppColors.textTertiary;

  // ─── Background & Surface Colors ─────────────────────────────

  Color get backgroundColor =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;

  Color get surfaceColor =>
      isDarkMode ? AppColors.darkSurface : AppColors.surface;

  Color get surfaceVariantColor =>
      isDarkMode ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;

  // ─── Input Colors ─────────────────────────────────────────────

  Color get inputFillColor =>
      isDarkMode ? AppColors.darkInputFill : AppColors.inputFill;

  // ─── Border & Divider ─────────────────────────────────────────

  Color get borderColor => isDarkMode ? AppColors.darkBorder : AppColors.border;

  Color get dividerColor =>
      isDarkMode ? AppColors.darkDivider : AppColors.divider;

  // ─── Shadows ──────────────────────────────────────────────────

  List<BoxShadow> get cardShadow =>
      isDarkMode ? AppColors.darkCardShadow : AppColors.cardShadow;

  List<BoxShadow> get softShadow =>
      isDarkMode ? AppColors.darkSoftShadow : AppColors.softShadow;

  // ─── UI States ────────────────────────────────────────────────

  Color get disabledColor => AppColors.disabled;

  Color get disabledTextColor => AppColors.disabledText;

  Color get overlayColor => AppColors.overlay;

  // ─── Text Opacity ─────────────────────────────────────────────

  Color get textSecondary60 => textSecondary.withValues(alpha: 0.6);

  Color get textSecondary50 => textSecondary.withValues(alpha: 0.5);
}
