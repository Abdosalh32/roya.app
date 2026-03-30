// lib/features/auth/controllers/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../data/models/login_model.dart';
import '../data/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage.dart';
import 'package:roya/core/router/route_names.dart';

/// ─────────────────────────────────────────────────
/// متحكم تسجيل الدخول
/// يُدير الحالة ومنطق الأعمال لشاشة تسجيل الدخول
/// ─────────────────────────────────────────────────
class AuthController extends GetxController {
  final AuthRepository _repository;

  AuthController(this._repository);

  // ─── TextEditingControllers ─────────────────────
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // ─── مفتاح النموذج للتحقق من المُدخلات ──────────
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ─── الحالات التفاعلية ──────────────────────────
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isPasswordVisible = false.obs;

  // ─── تبديل ظهور كلمة المرور ─────────────────────
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// تسجيل الدخول — يتحقق أولاً ثم يستدعي الـ repository
  Future<void> login(BuildContext context) async {
    // إخفاء رسالة الخطأ السابقة
    errorMessage.value = '';

    // التحقق من صحة النموذج
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final request = LoginRequestModel(
        phone: phoneController.text.trim(),
        password: passwordController.text,
      );

      final response = await _repository.login(request);

      // حفظ بيانات المصادقة في التخزين الآمن
      if (response.token != null) {
        await SecureStorage.saveToken(response.token!);
      }
      if (response.user?.id != null) {
        await SecureStorage.saveUserId(response.user!.id!);
      }
      if (response.user?.shop?.id != null) {
        await SecureStorage.saveShopId(response.user!.shop!.id!);
      }

      // الانتقال إلى لوحة التحكم باستخدام GoRouter
      if (context.mounted) {
        context.go(RouteNames.dashboard);
      }
    } catch (e) {
      // عرض رسالة الخطأ تحت النموذج مباشرةً
      errorMessage.value = e.toString();
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
