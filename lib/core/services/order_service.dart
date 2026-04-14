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

  /// جلب سعر التوصيل لمنطقة أو موقع محدد
  Future<Map<String, dynamic>> fetchDeliveryPrice({
    int? toRegionId,
    int? fromRegionId,
    String? postalCode,
    double? lat,
    double? lng,
    int? shopId,
  }) async {
    try {
      final params = <String, dynamic>{};
      // prefer explicit region params used by backend: from_region_id, to_region_id
      if (fromRegionId != null) params['from_region_id'] = fromRegionId;
      if (toRegionId != null) params['to_region_id'] = toRegionId;
      if (postalCode != null) params['postal_code'] = postalCode;
      if (lat != null) params['lat'] = lat;
      if (lng != null) params['lng'] = lng;
      if (shopId != null) params['shop_id'] = shopId;

      // For the shop owner app, always use the shop-owner endpoint.
      final endpoint = ApiEndpoints.shopOwnerDeliveryFee;

      final response = await _apiClient.dio.get(
        endpoint,
        queryParameters: params,
      );

      final json = response.data as Map<String, dynamic>;
      // backend returns { success: true, data: { ... } }
      if (json['success'] == true && json['data'] != null) {
        return Map<String, dynamic>.from(json['data']);
      }

      // fallback: if response directly contains fields
      return json;
    } catch (e) {
      debugPrint('❌ OrderService.fetchDeliveryPrice error: $e');
      // Handle Dio HTTP errors gracefully: if 404 (route not found / area not served)
      try {
        if (e is DioException && e.response != null) {
          final status = e.response?.statusCode ?? 0;
          if (status == 404) {
            // return a safe structure the controller can consume
            return {
              'is_served': false,
              'delivery_price': 0.0,
              'currency': 'LYD',
              'error': 'not_found',
            };
          }
        }
      } catch (_) {}
      // fallback: return not served
      return {
        'is_served': false,
        'delivery_price': 0.0,
        'currency': 'LYD',
        'error': 'unexpected',
      };
    }
  }
}
