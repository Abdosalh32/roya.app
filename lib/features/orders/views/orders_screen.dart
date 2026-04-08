import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:roya/core/router/route_names.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';

import '../controllers/orders_controller.dart';
import 'widgets/completed_order_card.dart';
import 'widgets/ongoing_order_card.dart';
import 'widgets/order_item_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Put the controller if not already present
    final controller = Get.put(OrdersController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            SizedBox(height: 8.h),
            _buildOrderCategoryToggle(controller),
            SizedBox(height: 16.h),
            _buildCustomTabBar(controller),
            SizedBox(height: 16.h),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNewOrdersTab(controller),
                  _buildOngoingOrdersTab(controller),
                  _buildCompletedTab(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Center(
        child: Text(
          'nav_orders'.tr,
          style: AppTextStyles.headingMedium.copyWith(
            color: const Color(0xFF1976D2),
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCategoryToggle(OrdersController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    controller.selectedOrderCategory.value = 'standard',
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: controller.selectedOrderCategory.value == 'standard'
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(12.r),
                    ),
                    border: Border.all(
                      color:
                          controller.selectedOrderCategory.value == 'standard'
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'الطلبات العادية',
                    style: AppTextStyles.headingSmall.copyWith(
                      color:
                          controller.selectedOrderCategory.value == 'standard'
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedOrderCategory.value = 'manual',
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: controller.selectedOrderCategory.value == 'manual'
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(12.r),
                    ),
                    border: Border.all(
                      color: controller.selectedOrderCategory.value == 'manual'
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'الطلبات اليدوية',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: controller.selectedOrderCategory.value == 'manual'
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(OrdersController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECF0).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: controller.tabController,
        indicator: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: const Color(0xFF1976D2),
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.headingSmall.copyWith(fontSize: 14.sp),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
          fontSize: 14.sp,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'tab_new_orders'.tr),
          Tab(text: 'tab_ongoing_orders'.tr),
          Tab(text: 'tab_completed_orders'.tr),
        ],
      ),
    );
  }

  Widget _buildNewOrdersTab(OrdersController controller) {
    return Builder(
      builder: (context) => RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.fetchOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _buildDailyStatsCard(controller),
              SizedBox(height: 16.h),
              Obx(() {
                if (controller.isLoading.value &&
                    controller.newOrders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.errorMessage.value.isNotEmpty &&
                    controller.newOrders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(controller.errorMessage.value),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.newOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.newOrders[index];
                    return OrderItemCard(
                      order: order,
                      onTap: () => context.push(
                        RouteNames.orderDetail,
                        extra: {
                          'backendId': order.backendId,
                          'orderId': order.id,
                          'customerName': order.customerName,
                          'status': order.status,
                        },
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOngoingOrdersTab(OrdersController controller) {
    return Builder(
      builder: (context) => Obx(() {
        if (controller.ongoingOrders.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.fetchOrders,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 140.h),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 64.sp,
                        color: AppColors.border,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'no_ongoing_orders'.tr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchOrders,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.ongoingOrders.length,
              itemBuilder: (context, index) {
                final order = controller.ongoingOrders[index];
                return OngoingOrderCard(
                  order: order,
                  onTap: () => context.push(
                    RouteNames.orderDetail,
                    extra: {
                      'backendId': order.backendId,
                      'orderId': order.id,
                      'customerName': order.customerName,
                      'status': order.status,
                      'driverName': order.driverName,
                    },
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCompletedTab(OrdersController controller) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: controller.fetchOrders,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── شريط البحث ───
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'search_completed'.tr,
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // ─── بطاقات الإحصائيات ───
            Row(
              children: [
                // بطاقة الإجمالي
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'total_sales'.tr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          controller.completedTotalSales.toStringAsFixed(2),
                          style: AppTextStyles.headingLarge.copyWith(
                            color: Colors.white,
                            fontSize: 24.sp,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'this_month'.tr,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // بطاقة الطلبات المكتملة
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'completed_orders_count'.tr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '${controller.completedOrders.length}',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 24.sp,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          '+12%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFFD32F2F),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // ─── عنوان السجل ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'completed_history'.tr,
                  style: AppTextStyles.headingSmall.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'today_timeline'.tr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // ─── قائمة الطلبات ───
            Obx(() {
              final orders = controller.filteredCompletedOrders;
              if (orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      'no_completed_orders'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  // Check if we need to insert a divider for "Last week"
                  final order = orders[index];
                  final showLastWeekHeader =
                      index ==
                      2; // Hardcoded based on mockup structure for exactly index 2

                  return Column(
                    children: [
                      if (showLastWeekHeader &&
                          controller.searchQuery.value.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Text(
                            'last_week'.tr,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      CompletedOrderCard(
                        order: order,
                        onTap: () => context.push(
                          RouteNames.orderDetail,
                          extra: {
                            'backendId': order.backendId,
                            'orderId': order.id,
                            'customerName': order.customerName,
                            'status': order.status,
                            'driverName': order.driverName,
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStatsCard(OrdersController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'daily_stats_orders'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Icon(
                Icons.trending_up,
                color: const Color(0xFF1976D2),
                size: 24.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              '${controller.newOrders.length}',
              style: AppTextStyles.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 40.sp,
                height: 1,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: Text(
              'daily_increase_stats'.trParams({'percent': '12'}),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
