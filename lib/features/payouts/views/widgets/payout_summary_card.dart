import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../dashboard/data/models/dashboard_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PayoutSummaryCard extends StatelessWidget {
  final StatsModel? stats;
  final VoidCallback? onPayoutRequested;

  const PayoutSummaryCard({
    super.key,
    required this.stats,
    this.onPayoutRequested,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_LY',
      symbol: 'د.ل',
      decimalDigits: 2,
    );

    final totalDue = stats?.totalDue ?? 0.0;
    final totalSales = stats?.totalSales ?? 0.0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
                'الرصيد المستحق',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_rounded,
                color: const Color(0xFF1976D2),
                size: 24.sp,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            currencyFormat.format(totalDue),
            style: AppTextStyles.headingLarge.copyWith(
              color: Colors.white,
              fontSize: 32.sp,
              height: 1,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي المبيعات',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    currencyFormat.format(totalSales),
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              if (onPayoutRequested != null)
                ElevatedButton.icon(
                  onPressed: onPayoutRequested,
                  icon: Icon(Icons.add_circle_outline, size: 16.sp, color: AppColors.primary),
                  label: Text(
                    'طلب سحب',
                    style: AppTextStyles.labelButton.copyWith(
                      color: AppColors.primary,
                      fontSize: 12.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'ميزة السحب غير مفعلة',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
