import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';

import '../data/models/order_detail_model.dart';
import 'widgets/order_details_components.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String customerName;
  final String? initialStatus;
  final String? driverName;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.customerName,
    this.initialStatus,
    this.driverName,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String currentStatus;
  String? selectedDriver;
  late OrderDetailModel detail;

  final List<String> availableDrivers = [
    'أحمد محمد - سيارة فان',
    'ياسر علي - دراجة نارية',
    'محمود صالح - سيارة سيدان',
  ];

  @override
  void initState() {
    super.initState();
    currentStatus = widget.initialStatus ?? 'status_new'.tr;
    selectedDriver = widget.driverName;
    
    _initDetail();
  }

  void _initDetail() {
    detail = OrderDetailModel(
      orderNumber: widget.orderId.length > 10 ? 'RY177016#' : widget.orderId,
      status: currentStatus,
      date: '24 مايو 2026 • 04:30 مساءً',
      deliveryType: 'delivery',
      customerName: widget.customerName,
      customerCity: 'حي الأندلس، طرابلس',
      customerPhone: '+218910000001',
      products: [
        const OrderProductItem(
          name: 'محفظة جلدية',
          quantity: 1,
          price: 85.00,
          imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=200',
        ),
        const OrderProductItem(
          name: 'غطاء هاتف',
          quantity: 1,
          price: 60.00,
          imageUrl: 'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=200',
        ),
      ],
      paymentMethod: 'الدفع عند الاستلام (COD)',
      subtotal: 145.00,
      deliveryFee: 0,
      total: 145.00,
    );
  }

  void _updateStatus(String newStatus) {
    setState(() {
      currentStatus = newStatus;
      _initDetail(); // Update detail object with new status if needed (though it's mostly for index)
    });
  }

  int _getStatusIndex(String status) {
    if (status == 'status_new'.tr) return -1;
    if (status == 'status_accepted_timeline'.tr) return 0;
    if (status == 'status_driver_store'.tr) return 1;
    if (status == 'status_received'.tr) return 2;
    if (status == 'status_delivering'.tr) return 3;
    if (status == 'status_delivered_timeline'.tr) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Header (Dark Blue) ───
          OrderDarkHeader(
            orderId: detail.orderNumber,
            totalPrice: detail.total,
            currency: 'د.ل',
            paymentMethod: detail.paymentMethod,
            onBack: () => Navigator.of(context).pop(),
          ),

          // ─── Content ───
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Column(
                children: [
                  // Timeline
                  OrderStatusTimeline(currentIndex: _getStatusIndex(currentStatus)),
                  SizedBox(height: 16.h),

                  // Customer Card
                  CustomerInfoCard(
                    name: detail.customerName,
                    address: detail.customerCity,
                    avatarUrl: 'https://i.pravatar.cc/150?img=11',
                    onCall: () {},
                  ),
                  SizedBox(height: 16.h),

                  // Products Card
                  ProductsListCard(
                    products: detail.products.map((p) => ProductItemData(
                      name: p.name,
                      quantity: p.quantity,
                      price: p.price,
                      imageUrl: p.imageUrl,
                    )).toList(),
                    currency: 'د.ل',
                  ),
                  SizedBox(height: 16.h),

                  // Delivery Info Card
                  DeliveryDetailsCard(
                    deliveryDate: '04:30 مساءً',
                    driverName: selectedDriver,
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionPanel(),
    );
  }

  Widget _buildBottomActionPanel() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, MediaQuery.of(context).padding.bottom + 16.h),
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
      child: _buildActionButtons(),
    );
  }

  Widget _buildActionButtons() {
    // 1. New Order Logic
    if (currentStatus == 'status_new'.tr) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showConfirmDialog(isAccept: false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              icon: Icon(Icons.cancel_rounded, color: AppColors.danger, size: 18.sp),
              label: Text(
                'btn_reject'.tr,
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.danger, fontSize: 14.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _showConfirmDialog(isAccept: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              icon: Icon(Icons.check_circle_rounded, color: Colors.white, size: 18.sp),
              label: Text(
                'btn_accept_order'.tr,
                style: AppTextStyles.headingSmall.copyWith(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      );
    }
    
    // 2. Ongoing Order (No Driver yet)
    if (selectedDriver == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'driver_assign_title'.tr,
            style: AppTextStyles.headingSmall.copyWith(fontSize: 14.sp),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 12.h),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'driver_choose'.tr,
              labelStyle: AppTextStyles.bodyMedium,
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
            value: selectedDriver,
            items: availableDrivers.map((val) {
              return DropdownMenuItem(
                value: val,
                child: Text(val, style: AppTextStyles.bodyMedium),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedDriver = val?.split(' - ').first;
              });
            },
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: selectedDriver == null
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('assign_driver_success'.tr)),
                    );
                    _updateStatus('status_accepted_timeline'.tr);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(
              'btn_assign_driver'.tr,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }

    // 3. Ongoing Order (Driver Assigned) or Completed
    if (currentStatus == 'status_delivered_timeline'.tr || currentStatus == 'status_delivered'.tr || currentStatus == 'status_delivered_badge'.tr) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              icon: Icon(Icons.print_rounded, color: AppColors.primary, size: 18.sp),
              label: Text('print'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  Icon(Icons.check_circle_rounded, color: const Color(0xFF2E7D32), size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'status_delivered_timeline'.tr,
                    style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Default for other ongoing statuses (only timeline is visible as requested)
    return const SizedBox.shrink();
  }

  void _showConfirmDialog({required bool isAccept}) {
    Get.dialog(
      AlertDialog(
        title: Text(isAccept ? 'dialog_accept_title'.tr : 'dialog_reject_title'.tr),
        content: Text(isAccept ? 'dialog_accept_body'.tr : 'dialog_reject_body'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('btn_cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              _updateStatus(isAccept ? 'status_accepted_timeline'.tr : 'status_rejected'.tr);
            },
            child: Text(isAccept ? 'btn_accept'.tr : 'btn_reject'.tr),
          ),
        ],
      ),
    );
  }
}
