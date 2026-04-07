import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:roya/core/network/api_client.dart';
import 'package:roya/features/auth/data/models/login_model.dart';

class ProfileRepository extends GetxService {
  Dio get _dio => Get.find<DioClient>().dio;

  Future<ShopModel> getProfile() async {
    try {
      final response = await _dio.get('/api/shop-owner/profile');
      final data = response.data;

      if (data != null && data['data'] != null) {
        return ShopModel.fromJson(data['data']);
      }
      throw 'لم نتمكن من جلب بيانات الملف الشخصي.';
    } on DioException catch (e) {
      debugPrint('❌ ProfileRepository.getProfile DioException: \${e.message}');
      if (e.response?.statusCode == 404) {
        throw 'المرجو التأكد من وجود مسار /api/shop-owner/profile في الخادم';
      }
      throw e.response?.data?['message']?.toString() ??
          'فشل الاتصال بالخادم لجلب الملف الشخصي.';
    } catch (e) {
      if (e is String) rethrow;
      throw 'حدث خطأ غير متوقع. حاول مجدداً.';
    }
  }
}
