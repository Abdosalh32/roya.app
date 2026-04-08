import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/manual_order_controller.dart';
import 'widgets/client_details_section.dart';
import 'widgets/product_details_section.dart';
import 'widgets/delivery_location_section.dart';
import 'widgets/order_summary_card.dart';

class CreateManualOrderScreen extends GetView<ManualOrderController> {
  const CreateManualOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'إنشاء طلب يدوي',
            style: AppTextStyles.headingMedium,
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: AppColors.border, height: 1.0),
          ),
        ),
        body: Form(
          key: controller.formKey,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ClientDetailsSection(),
                      SizedBox(height: 24.h),
                      const ProductDetailsSection(),
                      SizedBox(height: 24.h),
                      const DeliveryLocationSection(),
                      SizedBox(height: 24.h),
                      const OrderSummaryCard(),
                      SizedBox(height: 32.h),

                      // Submit Button
                      Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.submitOrder(context),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  height: 24.h,
                                  width: 24.h,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'تأكيد الطلب',
                                  style: AppTextStyles.labelButton,
                                ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
