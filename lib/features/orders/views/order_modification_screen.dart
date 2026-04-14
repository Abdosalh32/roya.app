import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:roya/core/network/api_client.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';

import '../controllers/orders_controller.dart';
import '../data/models/order_modification_models.dart';

class OrderModificationScreen extends StatefulWidget {
  final int subOrderId;

  const OrderModificationScreen({super.key, required this.subOrderId});

  @override
  State<OrderModificationScreen> createState() =>
      _OrderModificationScreenState();
}

class _OrderModificationScreenState extends State<OrderModificationScreen> {
  final Map<int, RespondModificationRequest> _responses = {};
  bool _isLoading = true;
  String _errorMessage = '';

  List<SubOrderItemReview> acceptedItems = [];
  List<SubOrderItemReview> rejectedItems = [];

  bool get _canSubmit => _responses.length == rejectedItems.length;

  @override
  void initState() {
    super.initState();
    _fetchModificationDetails();
  }

  Future<void> _fetchModificationDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final dio = Get.find<DioClient>().dio;
      final response = await dio.get(
        '/api/orders/${widget.subOrderId}/modification-details',
      );

      final data = response.data['data']['reviews'] as List;
      final parsedReviews = data
          .map((json) => SubOrderItemReview.fromJson(json))
          .toList();

      acceptedItems = parsedReviews
          .where((r) => r.status == 'accepted')
          .toList();
      rejectedItems = parsedReviews
          .where((r) => r.status == 'rejected')
          .toList();

      _responses.clear();
      for (final item in rejectedItems) {
        if (item.rejectionType == 'out_of_stock') {
          _responses[item.subOrderItemId] = RespondModificationRequest(
            subOrderItemId: item.subOrderItemId,
            response: CustomerResponseAction.removeItem,
          );
        }
      }
    } catch (e) {
      _errorMessage = 'تعذر استرجاع التعديلات';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitResponses() async {
    if (!_canSubmit) return;
    try {
      await Get.find<OrdersController>().respondToModification(
        widget.subOrderId,
        _responses.values.toList(),
      );
      Get.back();
      if (Get.context != null) {
        Get.snackbar(
          'نجاح',
          'تم إرسال ردك بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.context != null) {
        Get.snackbar(
          'خطأ',
          'تعذر إرسال التعديل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Widget _buildRejectedItemRow(SubOrderItemReview item) {
    final bool isOutOfStock = item.rejectionType == 'out_of_stock';
    final RespondModificationRequest? currentResponse =
        _responses[item.subOrderItemId];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.remove_circle, color: Colors.red, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'منتج ${item.subOrderItemId}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (isOutOfStock)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade700,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'المنتج غير متوفر (تم حذفه)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              'اقتراح بديل: ${item.substituteName}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(
                      () => _responses[item.subOrderItemId] =
                          RespondModificationRequest(
                            subOrderItemId: item.subOrderItemId,
                            response: CustomerResponseAction.acceptSubstitute,
                          ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          currentResponse?.response ==
                              CustomerResponseAction.acceptSubstitute
                          ? Colors.green
                          : Colors.grey.shade200,
                      foregroundColor:
                          currentResponse?.response ==
                              CustomerResponseAction.acceptSubstitute
                          ? Colors.white
                          : Colors.black,
                    ),
                    child: Text(
                      'أقبل البديل ✅',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(
                      () => _responses[item.subOrderItemId] =
                          RespondModificationRequest(
                            subOrderItemId: item.subOrderItemId,
                            response: CustomerResponseAction.rejectSubstitute,
                          ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          currentResponse?.response ==
                              CustomerResponseAction.rejectSubstitute
                          ? Colors.red
                          : Colors.grey.shade200,
                      foregroundColor:
                          currentResponse?.response ==
                              CustomerResponseAction.rejectSubstitute
                          ? Colors.white
                          : Colors.black,
                    ),
                    child: Text('أرفض ❌', style: TextStyle(fontSize: 12.sp)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'تعديل الطلبية #${widget.subOrderId}',
          style: AppTextStyles.headingMedium,
        ),
        elevation: 0,
        backgroundColor: AppColors.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage, style: AppTextStyles.bodyMedium),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: _fetchModificationDetails,
                    child: Text('المحاولة مجدداً'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                if (acceptedItems.isNotEmpty) ...[
                  Text(
                    'المنتجات المقبولة ✅',
                    style: AppTextStyles.headingSmall,
                  ),
                  SizedBox(height: 12.h),
                  // Render Read-Only list of accepted items
                  ...acceptedItems.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'منتج ${item.subOrderItemId}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Divider(),
                  SizedBox(height: 24.h),
                ],
                Text(
                  'المنتجات المرفوضة ❌',
                  style: AppTextStyles.headingSmall.copyWith(color: Colors.red),
                ),
                SizedBox(height: 12.h),
                if (rejectedItems.isEmpty)
                  Center(
                    child: Text(
                      'لا يوجد منتجات مرفوضة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  ...rejectedItems.map((item) => _buildRejectedItemRow(item)),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: ElevatedButton(
            onPressed: _canSubmit ? _submitResponses : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'تأكيد',
              style: AppTextStyles.headingSmall.copyWith(
                color: _canSubmit ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
