import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';
import '../controllers/payouts_controller.dart';
import 'widgets/payout_summary_card.dart';
import 'widgets/payout_list_item.dart';
import 'widgets/request_payout_bottom_sheet.dart';

class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayoutsController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('المدفوعات', style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline_rounded, color: Colors.white, size: 24.sp),
            onPressed: () {
              Get.snackbar('مساعدة', 'هذه الشاشة تعرض لك الرصيد المستحق وسجل المبالغ المسحوبة.', snackPosition: SnackPosition.BOTTOM);
            },
          )
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await controller.refreshData();
          },
          child: Obx(() {
            if (controller.isLoading.value) {
              return const _PayoutsShimmer();
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return _buildErrorState(controller);
            }

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: PayoutSummaryCard(
                      stats: controller.summaryData.value?.stats,
                      onPayoutRequested: controller.canRequestPayout
                          ? () => _showRequestBottomSheet(context)
                          : null,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: _buildFilterTabs(controller),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 16.h),
                ),
                _buildPayoutsList(controller),
                SliverToBoxAdapter(
                  child: SizedBox(height: 40.h),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(PayoutsController controller) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFilterTab(controller, 'all', 'الكل'),
          _buildFilterTab(controller, 'pending', 'قيد الانتظار'),
          _buildFilterTab(controller, 'paid', 'مدفوع'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(PayoutsController controller, String check, String title) {
    final isSelected = controller.selectedFilter.value == check;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setFilter(check),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPayoutsList(PayoutsController controller) {
    final payouts = controller.filteredPayouts;
    if (payouts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_rounded, color: AppColors.border, size: 80.sp),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد عمليات سحب حالياً',
                  style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return PayoutListItem(payout: payouts[index]);
          },
          childCount: payouts.length,
        ),
      ),
    );
  }

  Widget _buildErrorState(PayoutsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.danger),
          SizedBox(height: 16.h),
          Text(
            controller.errorMessage.value,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => controller.fetchData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _showRequestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const RequestPayoutBottomSheet(),
    );
  }
}

class _PayoutsShimmer extends StatelessWidget {
  const _PayoutsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          SizedBox(height: 24.h),
          ...List.generate(
            5,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
