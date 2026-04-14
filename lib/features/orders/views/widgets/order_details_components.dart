import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';

/// ─── Order Header (Dark Blue) ───
class OrderDarkHeader extends StatelessWidget {
  final String orderId;
  final double totalPrice;
  final String currency;
  final String paymentMethod;
  final VoidCallback onBack;

  const OrderDarkHeader({
    super.key,
    required this.orderId,
    required this.totalPrice,
    required this.currency,
    required this.paymentMethod,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        bottom: 20.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2340), // Dark Blue
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
              Text(
                'order_details_title'.tr,
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white,
                  fontSize: 17.sp,
                ),
              ),
              SizedBox(width: 40.w),
            ],
          ),

          SizedBox(height: 20.h),

          // Info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Price (Right in Arabic/RTL)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'price_total'.tr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white54,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${totalPrice.toStringAsFixed(2)} $currency',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.credit_card_rounded,
                        color: Colors.white54,
                        size: 13.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        paymentMethod,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white54,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Order Number (Left in Arabic/RTL)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'order_number_short'.tr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white54,
                      fontSize: 10.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    orderId,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ─── Timeline Widget ───
class OrderStatusTimeline extends StatelessWidget {
  final int currentIndex; // -1 if "New", 0 for first step, etc.

  const OrderStatusTimeline({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStepData(
        icon: Icons.verified_user_rounded,
        label: 'ongoing_status_waiting_confirm'.tr,
      ),
      _TimelineStepData(
        icon: Icons.inventory_2_rounded,
        label: 'ongoing_status_preparing'.tr,
      ),
      _TimelineStepData(
        icon: Icons.store_rounded,
        label: 'ongoing_status_waiting_pickup'.tr,
      ),
      _TimelineStepData(
        icon: Icons.local_shipping_rounded,
        label: 'status_delivering'.tr,
      ),
      _TimelineStepData(
        icon: Icons.home_rounded,
        label: 'status_delivered_timeline'.tr,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          final isLast = i == steps.length - 1;

          final isDone = i < currentIndex;
          final isActive = i == currentIndex;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1A2340)
                              : isDone
                              ? const Color(0xFF1A2340).withValues(alpha: 0.1)
                              : const Color(0xFFF1F4F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step.icon,
                          color: isActive
                              ? Colors.white
                              : isDone
                              ? const Color(0xFF1A2340)
                              : const Color(0xFF94A3B8),
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        step.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 9.sp,
                          color: isActive
                              ? const Color(0xFF1A2340)
                              : const Color(0xFF94A3B8),
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 12.w,
                    height: 2,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF1A2340).withValues(alpha: 0.2)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TimelineStepData {
  final IconData icon;
  final String label;
  const _TimelineStepData({required this.icon, required this.label});
}

/// ─── Customer Card (Image Right, Call Left) ───
class CustomerInfoCard extends StatelessWidget {
  final String name;
  final String address;
  final String phone;
  final VoidCallback onCall;
  final VoidCallback onCopyPhone;

  const CustomerInfoCard({
    super.key,
    required this.name,
    required this.address,
    required this.phone,
    required this.onCall,
    required this.onCopyPhone,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseSectionCard(
      title: 'customer_info'.tr,
      icon: Icons.person_pin_rounded,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            // Details (Center)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        address,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 12.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 14.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 12.sp,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      GestureDetector(
                        onTap: onCopyPhone,
                        child: Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 14.sp,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Phone Button (Left in Arabic/RTL)
            GestureDetector(
              onTap: onCall,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF), // Light Blue
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.phone_rounded,
                  color: const Color(0xFF4F46E5), // Indigo
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── Driver Card (Image Right, Call Left) ───
class DriverInfoCard extends StatelessWidget {
  final String name;
  final String? phone;
  final VoidCallback? onCall;
  final VoidCallback? onCopyPhone;

  const DriverInfoCard({
    super.key,
    required this.name,
    this.phone,
    this.onCall,
    this.onCopyPhone,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone != null && phone!.isNotEmpty;
    
    return _BaseSectionCard(
      title: 'driver_info'.tr,
      icon: Icons.delivery_dining_rounded,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            // Details (Center)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.start,
                  ),
                  if (hasPhone) ...[
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            phone!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 12.sp,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        if (onCopyPhone != null) ...[
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: onCopyPhone,
                            child: Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 14.sp,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasPhone && onCall != null) ...[
              SizedBox(width: 12.w),
              // Phone Button (Left in Arabic/RTL)
              GestureDetector(
                onTap: onCall,
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF), // Light Blue
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.phone_rounded,
                    color: const Color(0xFF4F46E5), // Indigo
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ─── Products Card (Redesigned) ───
class ProductsListCard extends StatelessWidget {
  final List<ProductItemData> products;
  final String currency;

  const ProductsListCard({
    super.key,
    required this.products,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseSectionCard(
      title: '${'products_title'.tr} (${products.length})',
      icon: Icons.shopping_bag_rounded,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: products.map((product) {
            final isLast = product == products.last;
            return Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: isLast
                      ? BorderSide.none
                      : BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Image (Right)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            width: 52.w,
                            height: 52.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _productImagePlaceholder(),
                          )
                        : _productImagePlaceholder(),
                  ),
                  SizedBox(width: 12.w),
                  // Details (Center)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          '${'qty'.tr}: ${product.quantity}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Price (Left)
                  Text(
                    '${product.price.toStringAsFixed(2)} $currency',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _productImagePlaceholder() {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        Icons.image_rounded,
        color: AppColors.textSecondary,
        size: 22.sp,
      ),
    );
  }
}

class ProductItemData {
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  const ProductItemData({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });
}

/// ─── Delivery Info Card ───
class DeliveryDetailsCard extends StatelessWidget {
  final String deliveryDate;
  final String? driverName;

  const DeliveryDetailsCard({
    super.key,
    required this.deliveryDate,
    this.driverName,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseSectionCard(
      title: 'delivery_info_title'.tr,
      icon: Icons.local_shipping_rounded,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // Light Grey
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              // Delivery Date (Left)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'delivery_date'.tr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF10B981), // Emerald/Green
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      deliveryDate,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: const Color(0xFF1E293B),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Driver (Right)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'driver_label'.tr,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            driverName ?? '—',
                            style: AppTextStyles.headingSmall.copyWith(
                              color: const Color(0xFF1E293B),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_car_rounded,
                        color: const Color(0xFF1E293B),
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── Base Card Wrapper ───
class _BaseSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _BaseSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headingSmall.copyWith(fontSize: 14.sp),
                ),
                SizedBox(width: 8.w),
                Icon(icon, color: AppColors.primary, size: 18.sp),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          child,
        ],
      ),
    );
  }
}
