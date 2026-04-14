import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';

import '../../../data/models/order_modification_models.dart';

class ShopOwnerItemReviewRow extends StatefulWidget {
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;
  final SubOrderItemReviewRequest? currentReview;
  final ValueChanged<SubOrderItemReviewRequest> onReviewed;

  const ShopOwnerItemReviewRow({
    super.key,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
    this.currentReview,
    required this.onReviewed,
  });

  @override
  State<ShopOwnerItemReviewRow> createState() => _ShopOwnerItemReviewRowState();
}

class _ShopOwnerItemReviewRowState extends State<ShopOwnerItemReviewRow> {
  void _acceptItem() {
    widget.onReviewed(
      SubOrderItemReviewRequest(
        subOrderItemId: 0,
        status: ItemReviewStatus.accepted,
      ),
    );
  }

  void _showRejectBottomSheet(BuildContext context) {
    ItemRejectionType selectedType = ItemRejectionType.outOfStock;
    final substituteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20.w,
                right: 20.w,
                top: 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سبب الرفض', style: AppTextStyles.headingMedium),
                  SizedBox(height: 16.h),
                  RadioListTile<ItemRejectionType>(
                    title: Text(
                      'المنتج غير متوفر',
                      style: AppTextStyles.bodyMedium,
                    ),
                    value: ItemRejectionType.outOfStock,
                    groupValue: selectedType,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => selectedType = val!),
                  ),
                  RadioListTile<ItemRejectionType>(
                    title: Text('يوجد بديل', style: AppTextStyles.bodyMedium),
                    value: ItemRejectionType.hasSubstitute,
                    groupValue: selectedType,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => selectedType = val!),
                  ),
                  if (selectedType == ItemRejectionType.hasSubstitute) ...[
                    SizedBox(height: 12.h),
                    TextField(
                      controller: substituteController,
                      decoration: InputDecoration(
                        hintText: 'أدخل اسم البديل هنا',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text('إلغاء', style: AppTextStyles.bodyMedium),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onReviewed(
                              SubOrderItemReviewRequest(
                                subOrderItemId: 0,
                                status: ItemReviewStatus.rejected,
                                rejectionType: selectedType,
                                substituteName:
                                    selectedType ==
                                        ItemRejectionType.hasSubstitute
                                    ? substituteController.text
                                    : null,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'تأكيد الرفض',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isReviewed = widget.currentReview != null;
    final bool isAccepted =
        widget.currentReview?.status == ItemReviewStatus.accepted;
    final hasReviewType =
        widget.currentReview?.rejectionType == ItemRejectionType.outOfStock
        ? 'غير متوفر'
        : widget.currentReview?.substituteName;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
              image: widget.productImage != null
                  ? DecorationImage(
                      image: NetworkImage(widget.productImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.productImage == null
                ? const Icon(Icons.image_not_supported, color: Colors.grey)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'الكمية: ${widget.quantity} • ${widget.price.toStringAsFixed(2)} ד.ل',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                if (!isReviewed)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _acceptItem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          icon: Icon(
                            Icons.check,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            'مقبول',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRejectBottomSheet(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            side: BorderSide(color: Colors.red.shade600),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          icon: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: Colors.red.shade600,
                          ),
                          label: Text(
                            'مرفوض',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isAccepted
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      isAccepted ? 'مقبول ✅' : 'مرفوض ❌ ($hasReviewType)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isAccepted
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
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
