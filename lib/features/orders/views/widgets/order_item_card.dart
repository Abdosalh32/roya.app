import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';
import '../../controllers/orders_controller.dart';

class OrderItemCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderItemCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── أيقونة السلة ───
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0EC),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.shopping_basket_rounded,
                      color: const Color(0xFFD32F2F),
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // ─── التفاصيل (الوسط) ───
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          order.customerName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              order.currency,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              order.price.toStringAsFixed(2),
                              style: AppTextStyles.headingSmall.copyWith(
                                color: const Color(0xFF1976D2),
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // ─── الحالة والوقت ───
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0EC),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          order.status,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFFFF6B2C),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        order.timeElapsed,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
