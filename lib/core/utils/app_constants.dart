// lib/core/utils/app_constants.dart
class AppConstants {
  AppConstants._();

  static const String appName = 'رويا';
  static const String appVersion = '1.0.0';
  static const String currency = 'د.ل';
  static const String phonePrefix = '09';
  static const int phoneLength = 10;

  // Legacy keys to prevent breaking everything immediately, although they were asked to be deleted.
  // Wait, the instructions said: "DELETE everything else from app_constants.dart. Keep ONLY AppConstants class in app_constants.dart:"
  // And defined exactly what the class should contain. I will match exactly.
}
