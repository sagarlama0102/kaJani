import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;

  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

  Color get textTertiary =>
      isDarkMode ? AppColors.darkTextTertiary : AppColors.textTertiary;

  Color get backgroundColor =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;

  Color get surfaceColor =>
      isDarkMode ? AppColors.darkSurface : AppColors.background;

  Color get surfaceVariantColor =>
      isDarkMode ? AppColors.darkSurfaceVariant : AppColors.background;

  Color get inputFillColor =>
      isDarkMode ? AppColors.darkInputFill : AppColors.inputFill;

  Color get borderColor =>
      isDarkMode ? AppColors.darkBorder : AppColors.border;

  Color get dividerColor =>
      isDarkMode ? AppColors.darkDivider : AppColors.divider;

  List<BoxShadow> get cardShadow =>
      isDarkMode ? AppColors.darkCardShadow : AppColors.cardShadow;

  List<BoxShadow> get softShadow =>
      isDarkMode ? AppColors.darkSoftShadow : AppColors.softShadow;

  Color get textSecondary60 =>
      isDarkMode
          ? AppColors.darkTextSecondary.withOpacity(0.6)
          : AppColors.textSecondary.withOpacity(0.6);

  Color get textSecondary50 =>
      isDarkMode
          ? AppColors.darkTextSecondary.withOpacity(0.5)
          : AppColors.textSecondary.withOpacity(0.5);
}