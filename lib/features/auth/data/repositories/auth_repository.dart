import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<LoginResponse> login(String phone, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/driver/login',
        data: {'phone': phone, 'password': password},
      );
      return LoginResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    }
  }
}
