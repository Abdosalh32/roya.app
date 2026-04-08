import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../data/models/payout_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PayoutDetailsScreen extends StatelessWidget {
  final PayoutModel payout;

  const PayoutDetailsScreen({super.key, required this.payout});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_LY',
      symbol: 'د.ل',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMMM yyyy - hh:mm a', 'ar');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('تفاصيل الدفعة', style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Amount big display
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: payout.statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      payout.status == 'paid'
                          ? Icons.check_circle_outline
                          : (payout.status == 'pending' ? Icons.access_time : Icons.cancel_outlined),
                      color: payout.statusColor,
                      size: 32.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    currencyFormat.format(payout.amount),
                    style: AppTextStyles.headingLarge.copyWith(
                      fontSize: 32.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: payout.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      payout.statusLabel,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: payout.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Details List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'تاريخ الطلب',
                    dateFormat.format(payout.requestedAt),
                  ),
                  if (payout.paidAt != null) ...[
                    _buildDivider(),
                    _buildDetailRow(
                      'تاريخ الدفع',
                      dateFormat.format(payout.paidAt!),
                    ),
                  ],
                  if (payout.referenceId != null) ...[
                    _buildDivider(),
                    _buildDetailRow(
                      'رقم المرجع',
                      payout.referenceId!,
                    ),
                  ],
                  if (payout.note != null && payout.note!.isNotEmpty) ...[
                    _buildDivider(),
                    _buildDetailRow(
                      'ملاحظات',
                      payout.note!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: 20.w,
      endIndent: 20.w,
    );
  }
}
