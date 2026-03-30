import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class OrderService extends GetxService {
  /// إنشاء طلب يدوي محاكاة (Mock Data Return)
  Future<Map<String, dynamic>> createManualOrder(
    Map<String, dynamic> data,
  ) async {
    try {
      // محاكاة تأخير التحميل من الخادم
      await Future.delayed(const Duration(seconds: 2));

      return {
        'success': true,
        'message': 'تم إنشاء الطلب بنجاح ✓',
        'order_id': 1046, // رقم طلب وهمي
      };
    } catch (e) {
      debugPrint('❌ OrderService.createManualOrder error: $e');
      throw 'error_unexpected'.tr;
    }
  }
}
