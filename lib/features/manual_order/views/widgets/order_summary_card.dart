import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../controllers/manual_order_controller.dart';

class OrderSummaryCard extends GetView<ManualOrderController> {
  const OrderSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0.00', 'en_US');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ملخص الطلب', style: AppTextStyles.headingSmall),
          SizedBox(height: 16.h),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سعر المنتج', style: AppTextStyles.bodyMedium),
                Text(
                  '${currencyFormatter.format(controller.subtotal.value)} د.ل',
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('رسوم التوصيل الثابتة', style: AppTextStyles.bodyMedium),
              Text(
                '${currencyFormatter.format(controller.deliveryFee)} د.ل',
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
          Divider(color: AppColors.border, height: 24.h),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي المطلوب',
                  style: AppTextStyles.headingMedium.copyWith(fontSize: 18.sp),
                ),
                Text(
                  '${currencyFormatter.format(controller.totalCharge)} د.ل',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
