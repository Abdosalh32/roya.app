// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;
import '../storage/secure_storage.dart';

/// ─────────────────────────────────────────────────
/// عميل Dio المُهيَّأ مسبقاً مع الـ Interceptors
/// يُسجَّل كـ GetxService حتى يبقى طوال دورة حياة التطبيق
/// ─────────────────────────────────────────────────
class DioClient extends GetxService {
  late Dio _dio;

  Dio get dio => _dio;

  Future<DioClient> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);

    return this;
  }
}

/// ─────────────────────────────────────────────────
/// مُعترض المصادقة — يُضيف Bearer Token تلقائياً
/// لكل طلب API بعد تسجيل الدخول
/// ─────────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ DioError [${err.response?.statusCode}]: ${err.message}');
    handler.next(err);
  }
}

/// ─────────────────────────────────────────────────
/// ApiClient — اسم مستعار للتوافق مع الكود القديم
/// ─────────────────────────────────────────────────
typedef ApiClient = DioClient;
