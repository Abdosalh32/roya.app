import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';
import '../../controllers/orders_controller.dart';

class OngoingOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onAssignDriver;

  const OngoingOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onAssignDriver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── الصف العلوي: رقم الطلب + الوقت + الحالة ───
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              children: [
                // Order number (On the Right in RTL)
                Text(
                  order.id,
                  style: AppTextStyles.headingSmall.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),
                // Time elapsed
                Text(
                  order.timeElapsed,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
                const Spacer(),
                // Status badge (On the Left in RTL)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: _getStatusBgColor(),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _getStatusBorderColor(), width: 0.5),
                  ),
                  child: Text(
                    order.status,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getStatusTextColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          Divider(color: AppColors.border.withValues(alpha: 0.5), height: 1),
          SizedBox(height: 12.h),

          // ─── الصف الأوسط: اسم العميل + سعر + عدد المنتجات ───
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                // Avatar (On the Right in RTL)
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: const Color(0xFFE8F0FB),
                  child: Icon(Icons.person_rounded, color: AppColors.primary, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                // Customer name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 15.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        order.itemCount == 1
                            ? 'order_items_count_one'.tr
                            : 'order_items_count'.trParams({'count': order.itemCount.toString()}),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.sp,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                // Price & item count (On the Left in RTL)
                Text(
                  '${order.currency} ${order.price.toStringAsFixed(2)}',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: const Color(0xFF1976D2),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          Divider(color: AppColors.border.withValues(alpha: 0.5), height: 1),

          // ─── الصف السفلي: سائق / تعيين سائق ───
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
            child: order.driverName != null
                ? _buildDriverAssigned()
                : _buildDriverNotAssigned(),
          ),
        ],
      ),
    );
  }

  // ─── السائق تم تعيينه ───
  Widget _buildDriverAssigned() {
    return Row(
      children: [
        Icon(Icons.local_shipping_rounded, color: AppColors.textSecondary, size: 18.sp),
        SizedBox(width: 8.w),
        // Driver info
        Text(
          '${'driver_prefix'.tr} ${order.driverName}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13.sp,
          ),
        ),
        const Spacer(),
        // Details button
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'btn_details'.tr,
                style: AppTextStyles.headingSmall.copyWith(
                  color: const Color(0xFF1976D2),
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(width: 2.w),
              // Logical back icon (chevron_left in RTL is pointing right usually, but logical start/end icons are preferred)
              Icon(Icons.chevron_left_rounded, color: const Color(0xFF1976D2), size: 18.sp),
            ],
          ),
        ),
      ],
    );
  }

  // ─── السائق لم يتم تعيينه ───
  Widget _buildDriverNotAssigned() {
    return Row(
      children: [
        Icon(Icons.local_shipping_rounded, color: AppColors.textSecondary, size: 18.sp),
        SizedBox(width: 8.w),
        // Not assigned
        Text(
          '${'driver_prefix'.tr} ${'driver_not_assigned'.tr}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
          ),
        ),
        const Spacer(),
        // Assign driver button
        GestureDetector(
          onTap: onAssignDriver,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'btn_assign_driver_short'.tr,
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusBgColor() {
    if (order.status == 'ongoing_status_waiting_pickup'.tr) {
      return const Color(0xFFE3F2FD);
    } else if (order.status == 'ongoing_status_preparing'.tr) {
      return const Color(0xFFFFF0EC);
    }
    return const Color(0xFFE8F5E9);
  }

  Color _getStatusBorderColor() {
    if (order.status == 'ongoing_status_waiting_pickup'.tr) {
      return const Color(0xFF1976D2);
    } else if (order.status == 'ongoing_status_preparing'.tr) {
      return const Color(0xFFFF6B2C);
    }
    return const Color(0xFF4CAF50);
  }

  Color _getStatusTextColor() {
    if (order.status == 'ongoing_status_waiting_pickup'.tr) {
      return const Color(0xFF1976D2);
    } else if (order.status == 'ongoing_status_preparing'.tr) {
      return const Color(0xFFFF6B2C);
    }
    return const Color(0xFF2E7D32);
  }
}
