// lib/app/bindings/initial_binding.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/order_service.dart';
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
    // register DioClient and also expose the raw Dio instance for modules that expect it
    Get.putAsync(
      () => DioClient().init(),
    ).then((client) => Get.put<Dio>(client.dio));
    Get.putAsync(() => AuthService().init());
    Get.put(OrderService());

    // ─── مستودع ومتحكم المصادقة ───────────────────
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<AuthController>(() => AuthController(Get.find()));

    // ─── مستودع ومتحكم لوحة التحكم ─────────────────
    Get.lazyPut<DashboardRepository>(() => DashboardRepository());
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
