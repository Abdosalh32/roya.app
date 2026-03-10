// lib/app/bindings/initial_binding.dart

import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';

/// ─────────────────────────────────────────────────
/// الربط الأولي للتطبيق — يُسجَّل فور بدء التطبيق
/// ─────────────────────────────────────────────────
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ─── خدمات الشبكة والمصادقة (GetxService) ───────
    Get.putAsync(() => DioClient().init());
    Get.putAsync(() => AuthService().init());

    // ─── مستودع ومتحكم المصادقة ───────────────────
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<AuthController>(() => AuthController(Get.find()));

    // ─── مستودع ومتحكم لوحة التحكم ─────────────────
    Get.lazyPut<DashboardRepository>(() => DashboardRepository());
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
