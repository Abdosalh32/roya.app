import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../controllers/manual_order_controller.dart';

class ClientDetailsSection extends GetView<ManualOrderController> {
  const ClientDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('بيانات العميل', style: AppTextStyles.headingSmall),
        SizedBox(height: 16.h),
        TextFormField(
          controller: controller.clientNameCtrl,
          decoration: InputDecoration(
            labelText: 'اسم العميل',
            labelStyle: AppTextStyles.bodyMedium,
            prefixIcon: const Icon(
              Icons.person_outline,
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
          validator: (value) => AppValidators.minLength(value, 3),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.clientPhoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'رقم الهاتف (09xxxxxxxx)',
            labelStyle: AppTextStyles.bodyMedium,
            prefixIcon: const Icon(
              Icons.phone_outlined,
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
          validator: AppValidators.libyanPhone,
        ),
      ],
    );
  }
}
