import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../controllers/manual_order_controller.dart';

class ProductDetailsSection extends GetView<ManualOrderController> {
  const ProductDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تفاصيل المنتج', style: AppTextStyles.headingSmall),
        SizedBox(height: 16.h),
        TextFormField(
          controller: controller.totalPriceCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'سعر المنتج',
            labelStyle: AppTextStyles.bodyMedium,
            suffixText: 'د.ل',
            prefixIcon: const Icon(
              Icons.attach_money_outlined,
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
          validator: AppValidators.positiveNumber,
        ),
        SizedBox(height: 12.h),
        Obx(
          () => DropdownButtonFormField<String>(
            initialValue: controller.selectedPackageType.value,
            decoration: InputDecoration(
              labelText: 'نوع التغليف',
              labelStyle: AppTextStyles.bodyMedium,
              prefixIcon: const Icon(
                Icons.inventory_2_outlined,
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
            items: controller.packageTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type, style: AppTextStyles.bodyLarge),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.selectedPackageType.value = val;
            },
          ),
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.descriptionCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'وصف المنتج (اختياري)',
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
        SizedBox(height: 16.h),
        Text('صورة المنتج (اختياري)', style: AppTextStyles.bodyMedium),
        SizedBox(height: 8.h),
        Obx(() {
          if (controller.imagePath.value.isNotEmpty) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(controller.imagePath.value),
                    height: 150.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: controller.removeImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.danger,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return InkWell(
            onTap: () => _showPicker(context),
            borderRadius: BorderRadius.circular(12.r),
            child: DottedBorder(
              color: AppColors.textSecondary,
              strokeWidth: 1.5,
              dashPattern: const [6, 4],
              borderType: BorderType.RRect,
              radius: Radius.circular(12.r),
              child: Container(
                height: 100.h,
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.textSecondary,
                      size: 32.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text('إرفاق صورة', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('معرض الصور'),
                onTap: () {
                  controller.pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('الكاميرا'),
                onTap: () {
                  controller.pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
