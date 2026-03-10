// lib/features/dashboard/controllers/dashboard_controller.dart

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = Get.find<DashboardRepository>();

  final Rx<DashboardModel?> dashboardData = Rx(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxInt unreadNotifications = 3.obs; // Default example value

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _repository.getDashboard();
      dashboardData.value = data;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('❌ DashboardController.fetchDashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    // Refresh without full loading state for pull-to-refresh
    try {
      final data = await _repository.getDashboard();
      dashboardData.value = data;
    } catch (e) {
      debugPrint('❌ DashboardController.refreshDashboard: $e');
      // On pull-to-refresh, we might not want to show a blocking error
    }
  }
}
