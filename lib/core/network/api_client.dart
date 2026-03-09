import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart' hide Response;

class ApiClient extends GetxService {
  late Dio _dio;

  Dio get dio => _dio;

  Future<ApiClient> init() async {
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

    // Add interceptors for logging or token handling
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );

    return this;
  }
}
