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
