import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:roya/core/network/api_client.dart';
import '../models/payout_model.dart';
import '../../../dashboard/data/models/dashboard_model.dart';

class PayoutsRepository extends GetxService {
  Dio get _dio => Get.find<DioClient>().dio;

  Future<DashboardModel> getSummary() async {
    try {
      final response = await _dio.get('/api/shop-owner/dashboard');
      return DashboardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('❌ PayoutsRepository.getSummary DioException: ${e.message}');
      _handleDioException(e);
    } catch (e) {
      throw 'حدث خطأ غير متوقع. حاول مجدداً.';
    }
  }

  Future<List<PayoutModel>> getPayouts() async {
    try {
      // TODO: Integration point for `/api/shop-owner/payouts`
      // Currently the backend does not return shop owner specific payouts in standard collection.
      // Keeping this safe layout: return empty array or fake data on 404
      
      final response = await _dio.get('/api/shop-owner/payouts');
      final data = response.data['data'] as List?;
      if (data == null) return [];
      
      return data.map((json) => PayoutModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('⚠️ Payouts endpoint missing (404). Fallback to empty list.');
        return [];
      }
      debugPrint('❌ PayoutsRepository.getPayouts DioException: ${e.message}');
      _handleDioException(e);
    } catch (e) {
      debugPrint('❌ PayoutsRepository.getPayouts unexpected error: $e');
      throw 'حدث خطأ في تحميل السحوبات.';
    }
  }

  Future<void> requestPayout(double amount, String? note) async {
    try {
      // TODO: Integration point for Request Payout endpoint
      // This is currently disabled in UI via feature flags, 
      // but keeping this stub ready for when backend supports it.
      await _dio.post('/api/shop-owner/payouts', data: {
        'amount': amount,
        if (note != null && note.isNotEmpty) 'note': note,
      });
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw 'انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مجدداً.';
    } else if (e.type == DioExceptionType.connectionError) {
      throw 'تعذّر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.';
    } else {
      final msg = e.response?.data?['message'];
      throw msg?.toString() ?? 'فشل الاتصال بالخادم.';
    }
  }
}
