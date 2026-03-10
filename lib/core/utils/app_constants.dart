// lib/core/utils/app_constants.dart

import 'package:flutter/material.dart';

/// ───────────────────────────────────────────────
/// ألوان التطبيق
/// ───────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0A2342);
  static const Color secondary = Color(0xFFFF6B2C);
  static const Color background = Color(0xFFF5F7FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1D23);
  static const Color textSecondary = Color(0xFF8A94A6);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color border = Color(0xFFE8ECF0);

  // Legacy aliases (for backward compatibility)
  static const Color accent = secondary;
  static const Color surface = card;
  static const Color error = danger;
  static const Color textBody = textPrimary;
  static const Color textGrey = textSecondary;
}

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

/// ───────────────────────────────────────────────
/// ثوابت التطبيق العامة
/// ───────────────────────────────────────────────
class AppConstants {
  AppConstants._();

  static const String appName = 'رويا';
  static const String appSubtitle = 'لوحة تحكم صاحب المتجر';
  static const String appVersion = 'الإصدار 1.0.0';

  // مفاتيح التخزين المحلي
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String shopIdKey = 'shop_id';
  static const String isFirstTimeKey = 'is_first_time';
}

/// ───────────────────────────────────────────────
/// نقاط نهاية API
/// ───────────────────────────────────────────────
class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/auth/shop-owner/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/me';
  static const String dashboard = '/shop/dashboard';
}

/// ───────────────────────────────────────────────
/// أسماء المسارات
/// ───────────────────────────────────────────────
class RouteNames {
  RouteNames._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String orders = '/orders';
  static const String products = '/products';
  static const String payout = '/payout';
  static const String manualOrder = '/manual-order';
  static const String profile = '/profile';
}

/// Legacy key class for backward compatibility
class AppKeys {
  static const String token = 'auth_token';
  static const String isFirstTime = 'is_first_time';
}
