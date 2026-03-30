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
        Obx(
          () => DropdownButtonFormField<String>(
            initialValue: controller.selectedDistrict.value,
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
            items: controller.districts.map((d) {
              return DropdownMenuItem(
                value: d,
                child: Text(d, style: AppTextStyles.bodyLarge),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.selectedDistrict.value = val;
            },
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
