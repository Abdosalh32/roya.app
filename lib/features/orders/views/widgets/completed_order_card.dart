import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';

import '../../controllers/orders_controller.dart';

class CompletedOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const CompletedOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد لون الشارة بناءً على الحالة
    final isArchived = order.status == 'status_archived'.tr;
    final badgeColor = isArchived ? AppColors.border : const Color(0xFFC8E6C9);
    final badgeTextColor = isArchived ? AppColors.textSecondary : const Color(0xFF2E7D32);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // جزء السعر والحالة (يسار)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.price.toStringAsFixed(2)} ${order.currency}',
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            order.status,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: badgeTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // جزء التفاصيل (يمين)
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // رقم الطلب والتاريخ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              order.date ?? '',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10.sp,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text(
                                '•',
                                style: TextStyle(color: AppColors.border, fontSize: 10.sp),
                              ),
                            ),
                            Text(
                              order.id,
                              style: AppTextStyles.headingSmall.copyWith(
                                color: AppColors.primary,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        // اسم العميل
                        Text(
                          order.customerName,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // عنوان العميل
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                order.customerAddress ?? '',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.location_on_rounded, color: AppColors.textSecondary, size: 14.sp),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // خط الفاصل
            Divider(color: AppColors.border, height: 1),

            // جزء السائق والخيارات
            // RTL makes the end as leading, right? Wait, row starts at leading edge.
            // Using MainAxisAlignment.spaceBetween
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 3 dots icon
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 18.sp),
                  ),
                  
                  // معلومات السائق
                  if (order.driverName != null)
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'driver'.tr,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 9.sp,
                              ),
                            ),
                            Text(
                              order.driverName!,
                              style: AppTextStyles.headingSmall.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8.w),
                        CircleAvatar(
                          radius: 16.r,
                          backgroundColor: AppColors.border,
                          backgroundImage: order.driverAvatar != null 
                              ? NetworkImage(order.driverAvatar!) 
                              : const NetworkImage('https://i.pravatar.cc/150?img=11'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
