// lib/core/storage/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<void> saveFirstTime() async {
    await _storage.write(key: 'is_first_time', value: 'false');
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // ─── User ID ─────────────────────────────────────
  static Future<void> saveUserId(int id) async {
    await _storage.write(key: 'user_id', value: id.toString());
  }

  static Future<int?> getUserId() async {
    final val = await _storage.read(key: 'user_id');
    if (val != null) return int.tryParse(val);
    return null;
  }

  // ─── Shop ID ─────────────────────────────────────
  static Future<void> saveShopId(int id) async {
    await _storage.write(key: 'shop_id', value: id.toString());
  }

  static Future<int?> getShopId() async {
    final val = await _storage.read(key: 'shop_id');
    if (val != null) return int.tryParse(val);
    return null;
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
