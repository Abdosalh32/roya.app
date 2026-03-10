// lib/core/storage/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_constants.dart';

/// ─────────────────────────────────────────────────
/// طبقة التخزين الآمن - تُغلّف FlutterSecureStorage
/// توفر واجهة ثابتة لجميع عمليات الحفظ والقراءة
/// ─────────────────────────────────────────────────
class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ─── Token ───────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  // ─── User ID ─────────────────────────────────────
  static Future<void> saveUserId(int id) async {
    await _storage.write(key: AppConstants.userIdKey, value: id.toString());
  }

  static Future<int?> getUserId() async {
    final val = await _storage.read(key: AppConstants.userIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  // ─── Shop ID ─────────────────────────────────────
  static Future<void> saveShopId(int id) async {
    await _storage.write(key: AppConstants.shopIdKey, value: id.toString());
  }

  static Future<int?> getShopId() async {
    final val = await _storage.read(key: AppConstants.shopIdKey);
    return val != null ? int.tryParse(val) : null;
  }

  // ─── Auth Status ──────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ─── Clear All ────────────────────────────────────
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
