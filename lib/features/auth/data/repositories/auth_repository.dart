// lib/features/auth/data/repositories/auth_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:roya/core/network/api_client.dart';

import '../models/login_model.dart';

/// ─────────────────────────────────────────────────
/// مستودع المصادقة — مسؤول فقط عن استدعاءات API
/// لا يحتوي على أي منطق تجاري (business logic)
/// ─────────────────────────────────────────────────
class AuthRepository extends GetxService {
  Dio get _dio => Get.find<DioClient>().dio;

  /// تسجيل الدخول — يُرسل بيانات المستخدم ويُعيد الاستجابة
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dio.post(
        '/api/auth/shop-owner/login',
        data: request.toJson(),
        options: Options(
          // Handle expected auth failures gracefully without throwing DioException.
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final data = (response.data is Map<String, dynamic>)
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return LoginResponseModel.fromJson(data);
      }

      if (response.statusCode == 401) {
        throw data['message']?.toString() ??
            'رقم الهاتف أو كلمة المرور غير صحيحة.';
      }

      if (response.statusCode == 422) {
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstErrors = errors.values.first;
          if (firstErrors is List && firstErrors.isNotEmpty) {
            throw firstErrors.first.toString();
          }
        }
        throw data['message']?.toString() ?? 'بيانات غير صحيحة.';
      }

      throw data['message']?.toString() ?? 'فشل تسجيل الدخول.';
    } on DioException catch (e) {
      debugPrint('❌ AuthRepository.login DioException: ${e.message}');
      _handleDioException(e);
    } catch (e) {
      // re-throw Arabic string errors directly
      if (e is String) rethrow;
      debugPrint('❌ AuthRepository.login unexpected error: $e');
      throw 'حدث خطأ غير متوقع. حاول مجدداً.';
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/shop-owner/logout');
    } on DioException catch (e) {
      debugPrint('❌ AuthRepository.logout DioException: ${e.message}');
      _handleDioException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'حدث خطأ غير متوقع. حاول مجدداً.';
    }
  }

  Future<LoginResponseModel> refreshToken() async {
    try {
      final response = await _dio.post('/api/auth/shop-owner/refresh');
      return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('❌ AuthRepository.refreshToken DioException: ${e.message}');
      _handleDioException(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'حدث خطأ غير متوقع. حاول مجدداً.';
    }
  }

  /// معالجة أخطاء Dio وتحويلها إلى رسائل عربية مقروءة
  Never _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw 'انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مجدداً.';

      case DioExceptionType.connectionError:
        throw 'تعذّر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        // 422 — أخطاء التحقق من المدخلات
        if (statusCode == 422) {
          if (data is Map<String, dynamic>) {
            final errors = data['errors'] as Map<String, dynamic>?;
            if (errors != null && errors.isNotEmpty) {
              final firstErrors = errors.values.first;
              if (firstErrors is List && firstErrors.isNotEmpty) {
                throw firstErrors.first.toString();
              }
            }
            throw data['message']?.toString() ?? 'بيانات غير صحيحة.';
          }
        }

        // 401 — بيانات اعتماد خاطئة
        if (statusCode == 401) {
          throw data?['message']?.toString() ??
              'رقم الهاتف أو كلمة المرور غير صحيحة.';
        }

        // 500 — خطأ في الخادم
        if (statusCode != null && statusCode >= 500) {
          throw 'الخادم غير متاح حالياً. حاول لاحقاً.';
        }

        throw data?['message']?.toString() ?? 'فشل الاتصال بالخادم.';

      default:
        throw 'حدث خطأ في الاتصال. حاول مجدداً.';
    }
  }
}
