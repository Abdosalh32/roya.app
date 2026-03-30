import 'package:get/get.dart';

class AppValidators {
  static String? libyanPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'phone_required'.tr;
    }
    if (!RegExp(r'^09\d{8}$').hasMatch(value)) {
      return 'phone_invalid'.tr;
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال القيمة'.tr;
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return 'أدخل قيمة صحيحة أكبر من صفر'.tr;
    }
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب'.tr;
    }
    if (value.length < min) {
      return 'يجب أن يكون النص $min أحرف على الأقل'.tr;
    }
    return null;
  }
}
