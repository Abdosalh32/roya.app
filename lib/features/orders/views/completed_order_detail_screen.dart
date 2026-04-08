import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../data/models/order_detail_model.dart';
import 'widgets/order_details_components.dart';

class CompletedOrderDetailScreen extends StatelessWidget {
  final OrderDetailModel order;

  const CompletedOrderDetailScreen({super.key, required this.order});

  Future<void> _callCustomer(BuildContext context) async {
    final phone = order.customerPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رقم الهاتف غير متوفر')));
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        await Clipboard.setData(ClipboardData(text: phone));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هذا الجهاز لا يدعم الاتصال. تم نسخ الرقم للحافظة'),
          ),
        );
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر فتح تطبيق الهاتف')));
      }
    } on PlatformException catch (_) {
      await Clipboard.setData(ClipboardData(text: phone));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح الاتصال الآن. تم نسخ الرقم للحافظة'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء محاولة الاتصال')),
        );
      }
    }
  }

  Future<void> _copyCustomerPhone(BuildContext context) async {
    final phone = order.customerPhone.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رقم الهاتف غير متوفر')));
      return;
    }

    await Clipboard.setData(ClipboardData(text: phone));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم نسخ رقم الهاتف')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ─── Header (Dark Blue) ───
          OrderDarkHeader(
            orderId: order.orderNumber,
            totalPrice: order.total,
            currency: 'د.ل',
            paymentMethod: order.paymentMethod,
            onBack: () => Navigator.of(context).pop(),
          ),

          // ─── Content ───
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Column(
                children: [
                  // Timeline (Delivered = Index 4)
                  const OrderStatusTimeline(currentIndex: 4),
                  SizedBox(height: 16.h),

                  // Customer Card
                  CustomerInfoCard(
                    name: order.customerName,
                    address: order.customerCity,
                    phone: order.customerPhone,
                    onCall: () => _callCustomer(context),
                    onCopyPhone: () => _copyCustomerPhone(context),
                  ),
                  SizedBox(height: 16.h),

                  // Products Card
                  ProductsListCard(
                    products: order.products
                        .map(
                          (p) => ProductItemData(
                            name: p.name,
                            quantity: p.quantity,
                            price: p.price,
                            imageUrl: p.imageUrl,
                          ),
                        )
                        .toList(),
                    currency: 'د.ل',
                  ),
                  SizedBox(height: 16.h),

                  // Delivery Info Card
                  DeliveryDetailsCard(
                    deliveryDate: '04:30 مساءً',
                    driverName: 'أحمد المحمودي',
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 12.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(
                Icons.print_rounded,
                color: AppColors.primary,
                size: 18.sp,
              ),
              label: Text(
                'print'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF81C784)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: const Color(0xFF2E7D32),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'status_delivered_timeline'.tr,
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
