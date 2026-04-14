import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:roya/core/network/api_client.dart';
import 'package:roya/features/auth/data/models/login_model.dart';

class ProfileRepository extends GetxService {
  dio.Dio get _dio => Get.find<DioClient>().dio;

  Future<ShopModel> getProfile() async {
    try {
      final response = await _dio.get('/api/shop-owner/profile');
      final data = response.data;

      if (data != null && data['data'] != null) {
        return ShopModel.fromJson(data['data']);
      }
      throw 'لم نتمكن من جلب بيانات الملف الشخصي.';
    } on dio.DioException catch (e) {
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

  Future<ShopModel> updateProfile(
    Map<String, dynamic> payload, {
    File? logoFile,
    File? bannerFile,
  }) async {
    try {
      dio.FormData? formData;

      // If we have files, use FormData
      if (logoFile != null || bannerFile != null) {
        formData = dio.FormData.fromMap({
          ...payload,
          if (logoFile != null)
            'logo': await dio.MultipartFile.fromFile(
              logoFile.path,
              filename: logoFile.path.split('/').last,
            ),
          if (bannerFile != null)
            'banner': await dio.MultipartFile.fromFile(
              bannerFile.path,
              filename: bannerFile.path.split('/').last,
            ),
        });

        final response = await _dio.put(
          '/api/shop-owner/profile',
          data: formData,
        );

        final data = response.data;
        if (data != null && data['data'] != null) {
          return ShopModel.fromJson(data['data']);
        }
        throw 'فشل في تحديث الملف الشخصي.';
      }

      // No files, send JSON
      final response = await _dio.put(
        '/api/shop-owner/profile',
        data: payload,
      );

      final data = response.data;
      if (data != null && data['data'] != null) {
        return ShopModel.fromJson(data['data']);
      }
      throw 'فشل في تحديث الملف الشخصي.';
    } on dio.DioException catch (e) {
      debugPrint('❌ ProfileRepository.updateProfile DioException: \${e.message}');
      throw e.response?.data?['message']?.toString() ??
          'فشل الاتصال بالخادم لتحديث الملف الشخصي.';
    } catch (e) {
      if (e is String) rethrow;
      throw 'حدث خطأ غير متوقع. حاول مجدداً.';
    }
  }
}
