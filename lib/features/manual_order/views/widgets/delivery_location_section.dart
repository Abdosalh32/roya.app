import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../controllers/manual_order_controller.dart';

class DeliveryLocationSection extends GetView<ManualOrderController> {
  const DeliveryLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('موقع التسليم', style: AppTextStyles.headingSmall),
        SizedBox(height: 16.h),
        TextFormField(
          initialValue: 'طرابلس',
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'المدينة',
            labelStyle: AppTextStyles.bodyMedium,
            prefixIcon: const Icon(
              Icons.location_city_outlined,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          if (controller.isLoadingRegions.value) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return DropdownButtonFormField<int>(
            value: controller.selectedRegionId.value,
            decoration: InputDecoration(
              labelText: 'المنطقة',
              labelStyle: AppTextStyles.bodyMedium,
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.card,
            ),
            items: controller.regions.map((r) {
              return DropdownMenuItem<int>(
                value: r.id,
                child: Text(r.nameAr, style: AppTextStyles.bodyLarge),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.selectedRegionId.value = val;
            },
            validator: (value) => value == null ? 'مطلوب' : null,
          );
        }),
        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.addressDetailsCtrl,
          decoration: InputDecoration(
            labelText: 'العنوان التفصيلي (اختياري)',
            labelStyle: AppTextStyles.bodyMedium,
            prefixIcon: const Icon(
              Icons.home_outlined,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.card,
          ),
        ),
        SizedBox(height: 12.h),
        // Delivery price (read-only) placed under the area selection
        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.deliveryFeeCtrl,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'سعر التوصيل',
            labelStyle: AppTextStyles.bodyMedium,
            suffixText: 'د.ل',
            prefixIcon: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.card,
          ),
        ),

        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.deliveryNotesCtrl,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'ملاحظات التوصيل (اختياري)',
            labelStyle: AppTextStyles.bodyMedium,
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            filled: true,
            fillColor: AppColors.card,
          ),
        ),
      ],
    );
  }
}
