// lib/features/auth/views/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/utils/app_constants.dart';

/// ─────────────────────────────────────────────────
/// شاشة تسجيل الدخول
/// StatelessWidget مع Obx للحالات التفاعلية — بدون setState
/// ─────────────────────────────────────────────────
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => SafeArea(
            child: Column(
              children: [
                // ─── الجزء العلوي: الشعار واسم التطبيق ─────
                const _TopSection(),
                // ─── البطاقة البيضاء السفلية ─────────────────
                Expanded(child: _LoginCard(controller: controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── الجزء العلوي (40%) ──────────────────────────────
class _TopSection extends StatelessWidget {
  const _TopSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار التطبيق
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'ر',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // اسم التطبيق
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6.h),
            // العنوان الفرعي
            Text(
              AppConstants.appSubtitle,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── بطاقة تسجيل الدخول ──────────────────────────────
class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000), // black.withOpacity(0.06)
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // عنوان النموذج
              Text(
                'تسجيل الدخول',
                style: AppTextStyles.headingLarge,
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 24.h),

              // ─── حقل رقم الهاتف ────────────────────────
              _PhoneField(controller: controller),
              SizedBox(height: 16.h),

              // ─── حقل كلمة المرور ───────────────────────
              _PasswordField(controller: controller),
              SizedBox(height: 12.h),

              // ─── رسالة الخطأ ───────────────────────────
              _ErrorMessage(controller: controller),

              SizedBox(height: 20.h),

              // ─── زر تسجيل الدخول ───────────────────────
              _LoginButton(controller: controller),

              SizedBox(height: 24.h),

              // ─── رقم الإصدار ───────────────────────────
              Text(
                AppConstants.appVersion,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── حقل رقم الهاتف ──────────────────────────────────
class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.phoneController,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: AppTextStyles.bodyLarge,
      decoration: _inputDecoration(
        label: 'رقم الهاتف',
        prefixIcon: const Icon(
          Icons.phone_outlined,
          color: AppColors.textSecondary,
        ),
      ),
      validator: (value) {
        final phone = value?.trim() ?? '';
        if (phone.isEmpty) return 'رقم الهاتف مطلوب';
        // أرقام ليبيا تبدأ بـ 09 وطولها 10 أرقام
        if (!RegExp(r'^09\d{8}$').hasMatch(phone)) {
          return 'أدخل رقم هاتف ليبي صحيح (09xxxxxxxx)';
        }
        return null;
      },
    );
  }
}

// ─── حقل كلمة المرور ─────────────────────────────────
class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        obscureText: !controller.isPasswordVisible.value,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: AppTextStyles.bodyLarge,
        decoration: _inputDecoration(
          label: 'كلمة المرور',
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: AppColors.textSecondary,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        ),
        validator: (value) {
          final pass = value ?? '';
          if (pass.isEmpty) return 'كلمة المرور مطلوبة';
          if (pass.length < 6) {
            return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
          }
          return null;
        },
      ),
    );
  }
}

// ─── عرض رسالة الخطأ ─────────────────────────────────
class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.errorMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                msg,
                style: AppTextStyles.error,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── زر تسجيل الدخول ─────────────────────────────────
class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56.h,
        decoration: BoxDecoration(
          color: controller.isLoading.value
              ? AppColors.primary.withValues(alpha: 0.7)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14.r),
            onTap: controller.isLoading.value
                ? null
                : () => controller.login(context),
            child: Center(
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text('تسجيل الدخول', style: AppTextStyles.labelButton),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── مساعد: تصميم حقول الإدخال ───────────────────────
InputDecoration _inputDecoration({
  required String label,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: AppTextStyles.bodyMedium,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
    ),
  );
}
