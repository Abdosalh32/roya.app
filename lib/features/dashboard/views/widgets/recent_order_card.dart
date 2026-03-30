// lib/features/dashboard/views/widgets/recent_order_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:get/get.dart';
import '../../data/models/dashboard_model.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';

class RecentOrderCard extends StatelessWidget {
  final RecentOrderModel order;
  final VoidCallback onTap;

  const RecentOrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // تنسيق السعر
    final currencyFormatter = NumberFormat('#,##0.00', 'en_US');
    final formattedTotal =
        '${currencyFormatter.format(order.total)} ${'currency'.tr}';

    // وقت الإنشاء
    final locale = Get.locale?.languageCode ?? 'ar';
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    timeago.setLocaleMessages('en', timeago.EnMessages());
    final timeAgoStr = timeago.format(order.createdAt, locale: locale);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── الجزء الأيمن ───
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'order_number'.trParams({
                              'number': order.orderNumber.toString(),
                            }),
                            style: AppTextStyles.headingSmall.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: order.statusColor,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              order.statusLabel,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        order.customerName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              order.regionName,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // ─── الجزء الأيسر ───
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedTotal,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      timeAgoStr,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
