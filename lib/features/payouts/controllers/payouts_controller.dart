import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repositories/payouts_repository.dart';
import '../data/models/payout_model.dart';
import 'package:roya/features/dashboard/data/models/dashboard_model.dart';

class PayoutsController extends GetxController {
  final PayoutsRepository _repository = Get.find<PayoutsRepository>();

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Summary data
  final Rx<DashboardModel?> summaryData = Rx(null);

  // Filters mode
  final RxString selectedFilter = 'all'.obs; // all, pending, paid

  // Payout history
  final RxList<PayoutModel> allPayouts = <PayoutModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  // Derived filtered computed list
  List<PayoutModel> get filteredPayouts {
    if (selectedFilter.value == 'all') {
      return allPayouts;
    }
    return allPayouts.where((p) => p.status == selectedFilter.value).toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Run endpoint fetches in parallel for efficiency
      final results = await Future.wait([
        _repository.getSummary(),
        _repository.getPayouts(),
      ]);

      summaryData.value = results[0] as DashboardModel;
      allPayouts.assignAll(results[1] as List<PayoutModel>);

    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('❌ PayoutsController.fetchData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    try {
      final results = await Future.wait([
        _repository.getSummary(),
        _repository.getPayouts(),
      ]);
      summaryData.value = results[0] as DashboardModel;
      allPayouts.assignAll(results[1] as List<PayoutModel>);
    } catch (e) {
      debugPrint('❌ PayoutsController.refreshData: $e');
      // For pull to refresh we may not want to display a blocking error
    }
  }

  // Form submission (currently unused if feature flag is disabled)
  Future<bool> submitPayoutRequest(double amount, String note) async {
    try {
      // Basic validation
      if (amount <= 0) {
        Get.snackbar('خطأ', 'المبلغ يجب أن يكون أكبر من صفر.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      final due = summaryData.value?.stats.totalDue ?? 0;
      if (amount > due) {
        Get.snackbar('خطأ', 'المبلغ يتجاوز الرصيد المستحق.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }

      await _repository.requestPayout(amount, note);
      
      // Request success
      Get.snackbar('نجاح', 'تم تقديم طلب السحب بنجاح.', snackPosition: SnackPosition.BOTTOM);
      
      // Refresh the data
      await fetchData();
      return true;
    } catch (e) {
      Get.snackbar('خطأ', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  bool get canRequestPayout {
    // Feature flag: set this to false if backend doesn't support request creation.
    // Assuming backend currently does not support creating a request
    return false;
  }
}
