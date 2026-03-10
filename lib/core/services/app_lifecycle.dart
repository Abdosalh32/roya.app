// lib/core/services/app_lifecycle.dart

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../features/dashboard/controllers/dashboard_controller.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh dashboard data when the app comes to foreground
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().refreshDashboard();
      }
    }
  }
}

// Helper to initialize the observer
void initLifecycleObserver() {
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
}
