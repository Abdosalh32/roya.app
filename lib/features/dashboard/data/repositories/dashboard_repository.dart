// lib/features/dashboard/data/repositories/dashboard_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_constants.dart';
import '../models/dashboard_model.dart';

class DashboardRepository extends GetxService {
  Dio get _dio => Get.find<DioClient>().dio;

  Future<DashboardModel> getDashboard() async {
    try {
      final response = await _dio.get(ApiEndpoints.dashboard);

      if (response.data['status'] == true) {
        return DashboardModel.fromJson(response.data['data']);
      } else {
        throw response.data['message'] ?? 'فشل تحميل بيانات لوحة التحكم';
      }
    } on DioException catch (e) {
      debugPrint(
        '❌ DashboardRepository.getDashboard DioException: ${e.message}',
      );
      _handleDioException(e);
    } catch (e) {
      if (e is String) rethrow;
      debugPrint('❌ DashboardRepository.getDashboard unexpected error: $e');
      throw 'حدث خطأ غير متوقع. حاول مجدداً.';
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
