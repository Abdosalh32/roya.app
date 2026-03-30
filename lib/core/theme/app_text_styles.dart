import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ───────────────────────────────────────────────
/// أنماط النصوص
/// ───────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelButton = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.card,
  );

  static const TextStyle error = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.danger,
  );
}
