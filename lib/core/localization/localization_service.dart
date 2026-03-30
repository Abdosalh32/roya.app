import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalizationService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final String _langKey = 'app_lang';

  // Default fallback language
  static const fallbackLocale = Locale('en', 'US');

  // Available Locales
  static final locales = [const Locale('ar', 'SA'), const Locale('en', 'US')];

  /// Get saved locale from storage or return default Arabic
  Future<Locale> getSavedLocale() async {
    final savedLang = await _storage.read(key: _langKey);
    if (savedLang == 'en') {
      return const Locale('en', 'US');
    }
    return const Locale('ar', 'SA'); // Default is Arabic
  }

  /// Change language and save to storage
  Future<void> changeLocale(String langCode) async {
    await _storage.write(key: _langKey, value: langCode);

    final locale = langCode == 'en'
        ? const Locale('en', 'US')
        : const Locale('ar', 'SA');

    Get.updateLocale(locale);
  }
}
