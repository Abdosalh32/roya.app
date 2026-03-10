// lib/core/services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/storage/secure_storage.dart';

/// ─────────────────────────────────────────────────
/// خدمة المصادقة — تُدير حالة تسجيل الدخول
/// تُسجَّل كـ GetxService لتبقى طوال دورة حياة التطبيق
/// ─────────────────────────────────────────────────
class AuthService extends GetxService {
  final RxBool _isLoggedIn = false.obs;

  bool get isLoggedIn => _isLoggedIn.value;
  RxBool get isLoggedInObs => _isLoggedIn;

  Future<AuthService> init() async {
    _isLoggedIn.value = await SecureStorage.isLoggedIn();
    debugPrint('✅ AuthService init — isLoggedIn: ${_isLoggedIn.value}');
    return this;
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
    _isLoggedIn.value = false;
  }
}
