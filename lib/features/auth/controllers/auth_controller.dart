import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;

  AuthController(this._repository);

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  Future<void> login() async {
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _repository.login(
        phoneController.text,
        passwordController.text,
      );

      // Save token and navigate (logic to be implemented in AuthService)
      Get.offAllNamed('/dashboard'); // Placeholder
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
