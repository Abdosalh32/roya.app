import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:roya/core/network/api_client.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/core/theme/app_text_styles.dart';
import 'package:roya/features/orders/controllers/orders_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/order_detail_model.dart';
import '../data/models/order_modification_models.dart';
import 'widgets/modification/shop_owner_item_review_row.dart';
import 'widgets/order_details_components.dart';

class OrderDetailScreen extends StatefulWidget {
  final int? backendId;
  final String orderId;
  final String customerName;
  final String? initialStatus;
  final String? driverName;

  const OrderDetailScreen({
    super.key,
    this.backendId,
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
  bool _isLoading = false;
  bool _isSubmitting = false;
  String _errorMessage = '';
  final Dio _dio = Get.find<DioClient>().dio;
  int? _actionOrderId;
  final TextEditingController _rejectionReasonController = TextEditingController();

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
    _actionOrderId = _resolvedBackendId;
    _fetchDetail();
  }

  void _initDetail() {
    final initialName = _cleanString(widget.customerName) ?? 'عميل';

    detail = OrderDetailModel(
      orderNumber: widget.orderId.length > 10 ? 'RY177016#' : widget.orderId,
      status: currentStatus,
      statusRaw: widget.initialStatus ?? 'pending',
      date: '24 مايو 2026 • 04:30 مساءً',
      deliveryType: 'delivery',
      customerName: initialName,
      customerCity: 'حي الأندلس، طرابلس',
      customerPhone: '+218910000001',
      driverName: widget.driverName,
      driverPhone: null,
      products: [
        const OrderProductItem(
          name: 'محفظة جلدية',
          quantity: 1,
          price: 85.00,
          imageUrl:
              'https://images.unsplash.com/photo-1627123424574-724758594e93?w=200',
        ),
        const OrderProductItem(
          name: 'غطاء هاتف',
          quantity: 1,
          price: 60.00,
          imageUrl:
              'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=200',
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
      _initDetail();
    });
  }

  int? get _resolvedBackendId {
    if (widget.backendId != null) return widget.backendId;
    return int.tryParse(widget.orderId.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  Future<void> _fetchDetail() async {
    final backendId = _resolvedBackendId;
    if (backendId == null) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final resp = await _dio.get('/api/shop-owner/orders/$backendId');
      final raw = resp.data;
      final json = _extractOrderMap(raw);
      if (json == null) {
        setState(() => _errorMessage = 'تعذر قراءة بيانات الطلب');
        return;
      }

      setState(() {
        _applyOrderJson(json);
      });
    } on DioException catch (e) {
      final msg = (e.response?.data is Map<String, dynamic>)
          ? (e.response?.data['message']?.toString() ??
                'فشل تحميل تفاصيل الطلب')
          : 'فشل تحميل تفاصيل الطلب';
      setState(() => _errorMessage = msg);
    } catch (_) {
      setState(() => _errorMessage = 'فشل تحميل تفاصيل الطلب');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, dynamic>? _extractOrderMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        if (data['order'] is Map<String, dynamic>) {
          return data['order'] as Map<String, dynamic>;
        }
        return data;
      }
      if (raw['order'] is Map<String, dynamic>) {
        return raw['order'] as Map<String, dynamic>;
      }
    }
    return null;
  }

  void _applyOrderJson(Map<String, dynamic> json) {
    _actionOrderId = _extractActionId(json) ?? _actionOrderId;

    final orderNumber = (json['order_number'] ?? json['id'] ?? widget.orderId)
        .toString();
    final createdAt = DateTime.tryParse((json['created_at'] ?? '').toString());
    final customer = json['customer'] as Map<String, dynamic>?;
    final user = (customer != null && customer['user'] is Map<String, dynamic>)
        ? customer['user'] as Map<String, dynamic>
        : (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : null;
    final region = json['region'] as Map<String, dynamic>?;
    final isAr = Get.locale?.languageCode != 'en';
    final items = (json['items'] is List)
        ? (json['items'] as List).whereType<Map<String, dynamic>>().map((item) {
            SubOrderItemReview? reviewModel;
            if (item['review'] != null) {
              reviewModel = SubOrderItemReview.fromJson(item['review']);
            } else {
              // try fetch from reviews list if parsing full reviews
              // Since we don't have access to global reviews here easily, we rely on backend injecting it or fetch it separately below.
            }

            return OrderProductItem(
              id: (item['id'] is int)
                  ? item['id']
                  : int.tryParse(item['id']?.toString() ?? ''),
              review: reviewModel,
              name:
                  ((isAr ? item['product_name_ar'] : item['product_name_en']) ??
                          item['product_name'] ??
                          item['name'] ??
                          'منتج')
                      .toString(),
              quantity: item['quantity'] is int
                  ? item['quantity'] as int
                  : int.tryParse((item['quantity'] ?? '1').toString()) ?? 1,
              price: item['unit_price'] is num
                  ? (item['unit_price'] as num).toDouble()
                  : item['price'] is num
                  ? (item['price'] as num).toDouble()
                  : double.tryParse(
                          (item['unit_price'] ??
                                  item['price'] ??
                                  item['subtotal'] ??
                                  '0')
                              .toString(),
                        ) ??
                        0,
              imageUrl: (item['product_image_url'] ?? item['image_url'])
                  ?.toString(),
            );
          }).toList()
        : detail.products;

    final subtotal = _toDouble(
      json['subtotal'] ?? json['items_subtotal'] ?? json['total'],
    );
    final deliveryFee = _toDouble(json['delivery_fee'] ?? 0);
    final total = _toDouble(
      json['total'] ?? json['total_amount'] ?? subtotal + deliveryFee,
    );
    final statusRaw = (json['status'] ?? '').toString().toLowerCase();

    final driver = json['collector_driver'] as Map<String, dynamic>?;

    detail = OrderDetailModel(
      orderNumber: orderNumber.endsWith('#') ? orderNumber : '$orderNumber#',
      status: _statusLabel(statusRaw),
      statusRaw: statusRaw,
      date: createdAt != null
          ? '${createdAt.day}/${createdAt.month}/${createdAt.year} • ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
          : detail.date,
      deliveryType: (json['delivery_type'] ?? 'delivery').toString(),
      customerName: _resolveCustomerName(json, customer, user),
      customerCity:
          (_cleanString(
            json['region_name'] ??
                region?['name_ar'] ??
                region?['name_en'] ??
                json['address_region_name'] ??
                detail.customerCity,
          ) ??
          detail.customerCity),
      customerPhone:
          (_cleanString(
            json['customer_phone'] ?? customer?['phone'] ?? user?['phone'],
          ) ??
          detail.customerPhone),
      driverName: _cleanString(
        driver?['name'],
      ),
      driverPhone: _cleanString(
        driver?['phone'],
      ),
      products: items,
      paymentMethod: (json['payment_method'] ?? detail.paymentMethod)
          .toString(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
    );

    currentStatus = detail.status;
    selectedDriver = detail.driverName ?? selectedDriver;

    try {
      final controller = Get.find<OrdersController>();
      controller.currentSubOrderItems.assignAll(items);
    } catch (_) {}
  }

  int? _extractActionId(Map<String, dynamic> json) {
    final candidates = [
      json['action_sub_order_id'],
      json['sub_order_id'],
      json['subOrderId'],
      json['suborder_id'],
      json['id'],
      if (json['sub_order'] is Map<String, dynamic>)
        (json['sub_order'] as Map<String, dynamic>)['id'],
      if (json['subOrder'] is Map<String, dynamic>)
        (json['subOrder'] as Map<String, dynamic>)['id'],
    ];

    for (final value in candidates) {
      if (value is int) return value;
      final parsed = int.tryParse((value ?? '').toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  int? _extractActionIdDeep(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final direct = _extractActionId(raw);
      if (direct != null) return direct;

      if (raw['sub_orders'] is List) {
        for (final item in (raw['sub_orders'] as List)) {
          final id = _extractActionIdDeep(item);
          if (id != null) return id;
        }
      }

      for (final value in raw.values) {
        final id = _extractActionIdDeep(value);
        if (id != null) return id;
      }
    }

    if (raw is List) {
      for (final item in raw) {
        final id = _extractActionIdDeep(item);
        if (id != null) return id;
      }
    }

    return null;
  }

  Future<int?> _resolveActionIdFromDetailFallback() async {
    final backendId = _resolvedBackendId;
    if (backendId == null) return null;

    try {
      final resp = await _dio.get('/api/shop-owner/orders/$backendId');
      final id = _extractActionIdDeep(resp.data);
      if (id != null) _actionOrderId = id;
      return id;
    } catch (_) {
      return null;
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String? _cleanString(dynamic value) {
    final text = (value ?? '').toString().trim();
    if (text.isEmpty) return null;

    final lower = text.toLowerCase();
    if (text == '---' ||
        text == '-' ||
        lower == 'null' ||
        lower == 'n/a' ||
        lower == 'na' ||
        lower == 'unknown') {
      return null;
    }

    return text;
  }

  String _resolveCustomerName(
    Map<String, dynamic> json,
    Map<String, dynamic>? customer,
    Map<String, dynamic>? user,
  ) {
    final firstName = _cleanString(
      customer?['first_name'] ?? user?['first_name'],
    );
    final lastName = _cleanString(customer?['last_name'] ?? user?['last_name']);
    final fullNameFromParts = [
      if (firstName != null) firstName,
      if (lastName != null) lastName,
    ].join(' ').trim();

    return _cleanString(json['customer_name']) ??
        _cleanString(json['client_name']) ??
        _cleanString(json['username']) ??
        _cleanString(customer?['name']) ??
        _cleanString(customer?['full_name']) ??
        _cleanString(customer?['username']) ??
        _cleanString(customer?['display_name']) ??
        _cleanString(customer?['user_name']) ??
        _cleanString(user?['name']) ??
        _cleanString(user?['full_name']) ??
        _cleanString(user?['username']) ??
        _cleanString(user?['display_name']) ??
        _cleanString(fullNameFromParts) ??
        _cleanString(widget.customerName) ??
        'عميل';
  }

  Future<void> _callDriver() async {
    final rawPhone = detail.driverPhone;
    if (rawPhone == null || rawPhone.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('رقم الهاتف غير متوفر')));
      }
      return;
    }

    final phone = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('رقم الهاتف غير متوفر')));
      }
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        await Clipboard.setData(ClipboardData(text: phone));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('هذا الجهاز لا يدعم الاتصال. تم نسخ الرقم للحافظة'),
            ),
          );
        }
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر فتح تطبيق الهاتف')));
      }
    } on PlatformException catch (_) {
      await Clipboard.setData(ClipboardData(text: phone));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح الاتصال الآن. تم نسخ الرقم للحافظة'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء محاولة الاتصال')),
        );
      }
    }
  }

  Future<void> _copyDriverPhone() async {
    final phone = detail.driverPhone?.trim();
    if (phone == null || phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('رقم الهاتف غير متوفر')));
      }
      return;
    }

    await Clipboard.setData(ClipboardData(text: phone));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم نسخ رقم الهاتف')));
    }
  }

  String _statusLabel(String status) {
    if (status == 'new' || status == 'pending') return 'status_new'.tr;
    if (status == 'confirmation') return 'ongoing_status_waiting_confirm'.tr;
    if (status == 'preparing' ||
        status == 'accepted' ||
        status == 'confirmed') {
      return 'ongoing_status_preparing'.tr;
    }
    if (status == 'ready_for_pickup' || status == 'waiting_pickup') {
      return 'ongoing_status_waiting_pickup'.tr;
    }
    if (status == 'picked_up' || status == 'received')
      return 'ongoing_status_waiting_pickup'.tr;
    if (status == 'on_the_way' || status == 'delivering')
      return 'status_delivering'.tr;
    if (status == 'completed' || status == 'delivered')
      return 'status_delivered_timeline'.tr;
    if (status == 'rejected' || status == 'cancelled')
      return 'status_rejected'.tr;
    return currentStatus;
  }

  Future<void> _acceptOrder() async {
    final backendId = _actionOrderId ?? _resolvedBackendId;
    if (backendId == null || _isSubmitting) return;

    try {
      setState(() => _isSubmitting = true);
      await _dio.put('/api/shop-owner/orders/$backendId/accept');
      _updateStatus('ongoing_status_waiting_confirm'.tr);
      if (Get.isRegistered<OrdersController>()) {
        await Get.find<OrdersController>().fetchOrders();
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final rawMsg = (responseData is Map<String, dynamic>)
          ? responseData['message']?.toString() ?? ''
          : '';

      if (e.response?.statusCode == 404 && rawMsg.contains('SubOrder')) {
        final discoveredId = await _resolveActionIdFromDetailFallback();
        if (discoveredId != null && discoveredId != backendId) {
          try {
            await _dio.put('/api/shop-owner/orders/$discoveredId/accept');
            _updateStatus('ongoing_status_waiting_confirm'.tr);
            if (Get.isRegistered<OrdersController>()) {
              await Get.find<OrdersController>().fetchOrders();
            }
            return;
          } catch (_) {}
        }
      }

      if (e.response?.statusCode == 409) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                rawMsg.isNotEmpty
                    ? rawMsg
                    : 'لا يمكن قبول الطلب في حالته الحالية',
              ),
            ),
          );
        }
        await _fetchDetail();
        if (Get.isRegistered<OrdersController>()) {
          await Get.find<OrdersController>().fetchOrders();
        }
        return;
      }

      if (e.response?.statusCode == 500) {
        await _fetchDetail();
        if (Get.isRegistered<OrdersController>()) {
          await Get.find<OrdersController>().fetchOrders();
        }

        final acceptedAfterRefresh =
            currentStatus == 'ongoing_status_waiting_confirm'.tr ||
            currentStatus == 'ongoing_status_preparing'.tr ||
            currentStatus == 'ongoing_status_waiting_pickup'.tr ||
            currentStatus == 'status_accepted_timeline'.tr;

        if (acceptedAfterRefresh) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تم قبول الطلب بنجاح رغم خطأ الاستجابة من الخادم',
                ),
              ),
            );
          }
          return;
        }
      }

      final msg = (e.response?.data is Map<String, dynamic>)
          ? (e.response?.data['message']?.toString() ?? 'تعذر قبول الطلب')
          : 'تعذر قبول الطلب';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _rejectOrder({String? reason}) async {
    final backendId = _actionOrderId ?? _resolvedBackendId;
    if (backendId == null || _isSubmitting) return;

    final rejectionReason = reason?.trim() ?? _rejectionReasonController.text.trim();
    if (rejectionReason.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('rejection_reason_required'.tr)),
        );
      }
      return;
    }

    try {
      setState(() => _isSubmitting = true);
      await _dio.put(
        '/api/shop-owner/orders/$backendId/reject',
        data: {'reason': rejectionReason},
      );
      _updateStatus('status_rejected'.tr);
      if (Get.isRegistered<OrdersController>()) {
        await Get.find<OrdersController>().fetchOrders();
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final rawMsg = (responseData is Map<String, dynamic>)
          ? responseData['message']?.toString() ?? ''
          : '';

      if (e.response?.statusCode == 404 && rawMsg.contains('SubOrder')) {
        final discoveredId = await _resolveActionIdFromDetailFallback();
        if (discoveredId != null && discoveredId != backendId) {
          try {
            await _dio.put(
              '/api/shop-owner/orders/$discoveredId/reject',
              data: {'reason': rejectionReason},
            );
            _updateStatus('status_rejected'.tr);
            if (Get.isRegistered<OrdersController>()) {
              await Get.find<OrdersController>().fetchOrders();
            }
            return;
          } catch (_) {}
        }
      }

      if (e.response?.statusCode == 409) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                rawMsg.isNotEmpty
                    ? rawMsg
                    : 'لا يمكن رفض الطلب في حالته الحالية',
              ),
            ),
          );
        }
        await _fetchDetail();
        if (Get.isRegistered<OrdersController>()) {
          await Get.find<OrdersController>().fetchOrders();
        }
        return;
      }

      final msg = (e.response?.data is Map<String, dynamic>)
          ? (e.response?.data['message']?.toString() ?? 'تعذر رفض الطلب')
          : 'تعذر رفض الطلب';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _markReadyForPickup() async {
    final backendId = _actionOrderId ?? _resolvedBackendId;
    if (backendId == null || _isSubmitting) return;

    try {
      setState(() => _isSubmitting = true);

      DioException? lastDioError;
      var updated = false;

      final attempts = [
        () => _dio.put('/api/shop-owner/orders/$backendId/ready-for-pickup'),
        () => _dio.put('/api/shop-owner/orders/$backendId/ready_for_pickup'),
        () => _dio.patch(
          '/api/shop-owner/orders/$backendId/status',
          data: {'status': 'ready_for_pickup'},
        ),
        () => _dio.put(
          '/api/shop-owner/orders/$backendId/status',
          data: {'status': 'ready_for_pickup'},
        ),
      ];

      for (final call in attempts) {
        try {
          await call();
          updated = true;
          break;
        } on DioException catch (e) {
          lastDioError = e;
          if (e.response?.statusCode == 404) {
            continue;
          }
          rethrow;
        }
      }

      if (!updated) {
        final msg = (lastDioError?.response?.data is Map<String, dynamic>)
            ? (lastDioError?.response?.data['message']?.toString() ??
                  'لا يوجد مسار في الخادم لتحديث الطلب إلى جاهز للاستلام')
            : 'لا يوجد مسار في الخادم لتحديث الطلب إلى جاهز للاستلام';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
        return;
      }

      _updateStatus('ongoing_status_waiting_pickup'.tr);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ready_pickup_success'.tr)));
      }
      if (Get.isRegistered<OrdersController>()) {
        await Get.find<OrdersController>().fetchOrders();
      }
    } on DioException catch (e) {
      final msg = (e.response?.data is Map<String, dynamic>)
          ? (e.response?.data['message']?.toString() ?? 'تعذر تحديث حالة الطلب')
          : 'تعذر تحديث حالة الطلب';
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  int _getStatusIndex(String status) {
    if (status == 'status_new'.tr) return -1;
    if (status == 'ongoing_status_waiting_confirm'.tr) return 0;
    if (status == 'ongoing_status_preparing'.tr) return 1;
    if (status == 'ongoing_status_waiting_pickup'.tr) return 2;
    if (status == 'status_accepted_timeline'.tr) return 0;
    if (status == 'status_driver_store'.tr) return 2;
    if (status == 'status_received'.tr) return 2;
    if (status == 'status_delivering'.tr) return 3;
    if (status == 'status_delivered_timeline'.tr) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                    child: Column(
                      children: [
                        // Timeline
                        OrderStatusTimeline(
                          currentIndex: _getStatusIndex(currentStatus),
                        ),
                        SizedBox(height: 16.h),

                        // Driver Card
                        if (detail.driverName != null)
                          DriverInfoCard(
                            name: detail.driverName!,
                            phone: detail.driverPhone,
                            onCall: detail.driverPhone != null ? _callDriver : null,
                            onCopyPhone: detail.driverPhone != null ? _copyDriverPhone : null,
                          ),
                        if (detail.driverName != null) SizedBox(height: 16.h),

                        // Products Card
                        if (detail.statusRaw == 'pending' ||
                            detail.statusRaw == 'new')
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المنتجات (مراجعة)',
                                  style: AppTextStyles.headingSmall,
                                ),
                                SizedBox(height: 12.h),
                                Obx(() {
                                  final controller =
                                      Get.find<OrdersController>();
                                  return Column(
                                    children: detail.products.map((item) {
                                      final id = item.id ?? 0;
                                      return ShopOwnerItemReviewRow(
                                        productName: item.name,
                                        productImage: item.imageUrl,
                                        quantity: item.quantity,
                                        price: item.price,
                                        currentReview:
                                            controller.itemReviews[id],
                                        onReviewed: (review) {
                                          final realReview =
                                              SubOrderItemReviewRequest(
                                                subOrderItemId: id,
                                                status: review.status,
                                                rejectionType:
                                                    review.rejectionType,
                                                substituteName:
                                                    review.substituteName,
                                              );
                                          controller.setItemReview(
                                            id,
                                            realReview,
                                          );
                                        },
                                      );
                                    }).toList(),
                                  );
                                }),
                              ],
                            ),
                          )
                        else if (detail.statusRaw ==
                            'awaiting_customer_modification')
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  'في انتظار رد الزبون على التعديلات',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              ProductsListCard(
                                products: detail.products
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
                            ],
                          )
                        else if (detail.statusRaw ==
                            'customer_modification_confirmed')
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  'الزبون قبل التعديلات ✅',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              ProductsListCard(
                                products: detail.products
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
                            ],
                          )
                        else
                          ProductsListCard(
                            products: detail.products
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
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 16.h,
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
      child: _buildActionButtons(),
    );
  }

  Widget _buildActionButtons() {
    if (detail.statusRaw == 'awaiting_customer_modification') {
      return const SizedBox.shrink(); // No action buttons
    }

    if (detail.statusRaw == 'pending' || detail.statusRaw == 'new') {
      return Obx(() {
        final controller = Get.find<OrdersController>();
        return ElevatedButton(
          onPressed: controller.canSubmitReview
              ? () {
                  final id = detail.backendId ?? _actionOrderId;
                  if (id != null) controller.submitItemReviews(id);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'قبول الطلب',
            style: AppTextStyles.headingSmall.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        );
      });
    }

    if (detail.statusRaw == 'customer_modification_confirmed') {
      return ElevatedButton(
        onPressed: () {
          final id = detail.backendId ?? _actionOrderId;
          if (id != null) Get.find<OrdersController>().confirmModification(id);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'تأكيد الطلب نهائياً',
          style: AppTextStyles.headingSmall.copyWith(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
      );
    }

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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(
                Icons.cancel_rounded,
                color: AppColors.danger,
                size: 18.sp,
              ),
              label: Text(
                'btn_reject'.tr,
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.danger,
                  fontSize: 14.sp,
                ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              icon: Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
              label: Text(
                'btn_accept_order'.tr,
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 2. Confirmation state: waiting for customer-service confirmation
    if (currentStatus == 'ongoing_status_waiting_confirm'.tr) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFF90CAF9)),
        ),
        child: Text(
          'status_confirmation_waiting_info'.tr,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xFF0D47A1),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // 3. Preparing state: shop owner marks order ready for driver pickup
    if (currentStatus == 'ongoing_status_preparing'.tr) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFFDBA74)),
            ),
            child: Text(
              'status_preparing_info'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF9A3412),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _markReadyForPickup,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
            label: Text(
              'btn_ready_for_pickup'.tr,
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
    }

    // 4. Ready for pickup state
    if (currentStatus == 'ongoing_status_waiting_pickup'.tr) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Text(
          'status_waiting_pickup_info'.tr,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    // 5. Delivered
    if (currentStatus == 'status_delivered_timeline'.tr ||
        currentStatus == 'status_delivered'.tr ||
        currentStatus == 'status_delivered_badge'.tr) {
      return Row(
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
      );
    }

    // Default for other ongoing statuses (only timeline is visible as requested)
    return const SizedBox.shrink();
  }

  void _showConfirmDialog({required bool isAccept}) {
    if (!isAccept) {
      // Show rejection dialog with reason input
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('dialog_reject_title'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dialog_reject_body'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _rejectionReasonController,
                maxLines: 3,
                maxLength: 500,
                autofocus: true,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'rejection_reason_hint'.tr,
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  counterStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _rejectionReasonController.clear();
                Navigator.of(ctx).pop();
              },
              child: Text('btn_cancel'.tr),
            ),
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      final reason = _rejectionReasonController.text.trim();
                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('rejection_reason_required'.tr),
                          ),
                        );
                        return;
                      }
                      Navigator.of(ctx).pop();
                      await _rejectOrder(reason: reason);
                    },
              child: Text('btn_reject'.tr),
            ),
          ],
        ),
      );
    } else {
      // Show accept dialog (unchanged)
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('dialog_accept_title'.tr),
          content: Text('dialog_accept_body'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('btn_cancel'.tr),
            ),
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      Navigator.of(ctx).pop();
                      await _acceptOrder();
                    },
              child: Text('btn_accept'.tr),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }
}
