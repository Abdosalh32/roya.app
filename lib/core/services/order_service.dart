import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import '../../data/models/region_model.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

class OrderService extends GetxService {
  ApiClient get _apiClient => Get.find<ApiClient>();

  /// إنشاء طلب يدوي عبر الـ API
  Future<Map<String, dynamic>> createManualOrder(FormData data) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.manualOrders,
        data: data,
      );

      final responseData = response.data;
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw responseData['message'] ?? 'فشل طلب إنشاء الطلب اليدوي';
      }
    } catch (e) {
      debugPrint('❌ OrderService.createManualOrder error: $e');
      throw 'error_unexpected'.tr;
    }
  }

  /// جلب قائمة المناطق
  Future<List<RegionModel>> fetchRegions() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.regions);
      final jsonResponse = response.data;

      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final data = jsonResponse['data'] as List;
        return data.map((json) => RegionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ OrderService.fetchRegions error: $e');
      throw 'فشل جلب قائمة المناطق'.tr;
    }
  }
}
