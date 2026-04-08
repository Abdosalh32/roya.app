// lib/features/dashboard/views/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import '../controllers/dashboard_controller.dart';
import '../data/models/dashboard_model.dart';
import 'widgets/stats_card.dart';
import 'widgets/recent_order_card.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';
import 'package:roya/core/router/route_names.dart';
import 'package:roya/core/localization/localization_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is registered via InitialBinding
    final controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshDashboard,
          child: Column(
            children: [
              // ─── رأس الصفحة (الهيدر) ───
              _buildHeader(controller),

              // ─── المحتوى القابل للتمرير ───
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const _DashboardShimmer();
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return _buildErrorState(controller);
                  }

                  final data = controller.dashboardData.value;
                  if (data == null) {
                    return const Center(child: Text('لا توجد بيانات متاحة'));
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── صف الإحصائيات ───
                        _buildStatsRow(data.stats),
                        SizedBox(height: 16.h),

                        // ─── زر إضافة طلب يدوي ───
                        _buildManualOrderButton(context),
                        SizedBox(height: 24.h),

                        // ─── مخطط المبيعات ───
                        _buildChartSection(data.weeklySales),
                        SizedBox(height: 24.h),

                        // ─── آخر الطلبات ───
                        _buildRecentOrdersSection(context, data.recentOrders),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── رأس الصفحة ───
  Widget _buildHeader(DashboardController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ─── اليسار: جرس الإشعارات ───
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
                color: AppColors.textPrimary,
              ),
              Obx(() {
                if (controller.unreadNotifications.value == 0) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${controller.unreadNotifications.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),

          // ─── زر تبديل اللغة ───
          IconButton(
            onPressed: () {
              final locService = Get.find<LocalizationService>();
              final currentLang = Get.locale?.languageCode ?? 'ar';
              final newLang = currentLang == 'ar' ? 'en' : 'ar';
              locService.changeLocale(newLang);
            },
            icon: const Icon(Icons.language_rounded),
            color: AppColors.textPrimary,
          ),

          // ─── اليمين: معلومات المتجر ───
          Expanded(
            child: Obx(() {
              final shop = controller.dashboardData.value?.shop;
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          shop == null ? 'loading'.tr : shop.name,
                          style: AppTextStyles.headingSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'dashboard_title'.tr,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: shop?.logo != null
                        ? NetworkImage(shop!.logo!)
                        : null,
                    child: shop?.logo == null
                        ? Icon(
                            Icons.storefront,
                            color: AppColors.primary,
                            size: 24.sp,
                          )
                        : null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── صف الإحصائيات ───
  Widget _buildStatsRow(StatsModel stats) {
    final fmt = NumberFormat('#,##0', 'en_US');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatsCard(
          icon: Icons.account_balance_wallet_outlined,
          label: 'stats_total_due'.tr,
          value: '${fmt.format(stats.totalDue)} د.ل',
          valueColor: AppColors.success,
        ),
        StatsCard(
          icon: Icons.trending_up_rounded,
          label: 'stats_total_sales'.tr,
          value: '${fmt.format(stats.totalSales)} د.ل',
          valueColor: AppColors.primary,
        ),
        StatsCard(
          icon: Icons.shopping_bag_outlined,
          label: 'stats_new_orders'.tr,
          value: '${stats.newOrdersCount}',
          valueColor: AppColors.secondary,
        ),
      ],
    );
  }

  // ─── زر إضافة طلب يدوي ───
  Widget _buildManualOrderButton(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RouteNames.manualOrder),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
              SizedBox(width: 12.w),
              Text(
                'add_manual_order'.tr,
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── رسم بياني للمبيعات ───
  Widget _buildChartSection(List<WeeklySaleModel> sales) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('weekly_sales_chart'.tr, style: AppTextStyles.headingSmall),
          SizedBox(height: 20.h),
          SizedBox(
            height: 200.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1000,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${sales[group.x.toInt()].day}\n${rod.toY.toInt()} د.ل',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            sales[value.toInt()].day,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10.sp,
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value % 250 != 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10.sp,
                          ),
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 250,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sales.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.amount,
                        color: AppColors.primary,
                        width: 14.w,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── قسم آخر الطلبات ───
  Widget _buildRecentOrdersSection(
    BuildContext context,
    List<RecentOrderModel> orders,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => context.go(RouteNames.orders),
              child: Row(
                children: [
                  const Icon(Icons.chevron_left_rounded, size: 18),
                  Text(
                    'view_all'.tr,
                    style: AppTextStyles.labelButton.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Text('recent_orders_title'.tr, style: AppTextStyles.headingSmall),
          ],
        ),
        SizedBox(height: 12.h),
        if (orders.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'لا توجد طلبات حديثة',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return RecentOrderCard(
                order: orders[index],
                onTap: () {
                  // TODO: ننتقل لتفاصيل الطلب
                },
              );
            },
          ),
      ],
    );
  }

  // ─── حالة الخطأ ───
  Widget _buildErrorState(DashboardController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.danger, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            controller.errorMessage.value,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: controller.fetchDashboard,
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }
}

// ─── هيكل التحميل (Shimmer) ───
class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            // Stats Row Shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) => _shimmerBox(108.w, 100.h)),
            ),
            SizedBox(height: 24.h),
            // Chart Shimmer
            _shimmerBox(double.infinity, 260.h),
            SizedBox(height: 24.h),
            // Orders Header Shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_shimmerBox(80.w, 20.h), _shimmerBox(100.w, 24.h)],
            ),
            SizedBox(height: 16.h),
            // Orders List Shimmer
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _shimmerBox(double.infinity, 100.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}
