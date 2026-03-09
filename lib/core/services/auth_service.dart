import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final _isLoggedIn = false.obs;

  bool get isLoggedIn => _isLoggedIn.value;

  Future<AuthService> init() async {
    final token = await _storage.read(key: 'token');
    _isLoggedIn.value = token != null;
    return this;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
    _isLoggedIn.value = true;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    _isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
