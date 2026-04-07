import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roya/core/network/api_client.dart';

class OrderModel {
  final int? backendId;
  final String id;
  final String customerName;
  final double price;
  final String currency;
  final String status;
  final String statusRaw;
  final String timeElapsed;
  final int itemCount;
  final String? driverName;
  final String orderType; // 'delivery' | 'pickup'

  final String? customerAddress;
  final String? driverAvatar;
  final String? date;

  OrderModel({
    this.backendId,
    required this.id,
    required this.customerName,
    required this.price,
    required this.currency,
    required this.status,
    this.statusRaw = '',
    required this.timeElapsed,
    this.itemCount = 1,
    this.driverName,
    this.orderType = 'delivery',
    this.customerAddress,
    this.driverAvatar,
    this.date,
  });

  OrderModel copyWith({String? driverName, String? status}) {
    return OrderModel(
      backendId: backendId,
      id: id,
      customerName: customerName,
      price: price,
      currency: currency,
      status: status ?? this.status,
      statusRaw: statusRaw,
      timeElapsed: timeElapsed,
      itemCount: itemCount,
      driverName: driverName ?? this.driverName,
      orderType: orderType,
      customerAddress: customerAddress,
      driverAvatar: driverAvatar,
      date: date,
    );
  }
}

class OrdersController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final Dio _dio = Get.find<DioClient>().dio;

  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final RxString selectedOrderCategory =
      'standard'.obs; // 'standard' or 'manual'

  List<OrderModel> get newOrders => allOrders
      .where((o) => _isNewStatus(o.statusRaw) && _isCorrectCategory(o))
      .toList();

  List<OrderModel> get ongoingOrders => allOrders
      .where((o) => _isOngoingStatus(o.statusRaw) && _isCorrectCategory(o))
      .toList();

  List<OrderModel> get completedOrders => allOrders
      .where((o) => _isCompletedStatus(o.statusRaw) && _isCorrectCategory(o))
      .toList();

  bool _isCorrectCategory(OrderModel o) {
    if (selectedOrderCategory.value == 'manual') {
      return o.orderType == 'manual' || o.orderType == 'manual_order';
    }
    return o.orderType != 'manual' && o.orderType != 'manual_order';
  }

  // Search query for completed orders
  final searchQuery = ''.obs;

  List<OrderModel> get filteredCompletedOrders {
    if (searchQuery.value.isEmpty) return completedOrders;
    return completedOrders.where((order) {
      final searchLower = searchQuery.value.toLowerCase();
      return order.id.toLowerCase().contains(searchLower) ||
          order.customerName.toLowerCase().contains(searchLower);
    }).toList();
  }

  double get completedTotalSales {
    return completedOrders.fold<double>(0, (sum, o) => sum + o.price);
  }

  final List<String> availableDrivers = [
    'جهاد خليفة - سيارة فان',
    'القنطراري - دراجة نارية',
    'رضوان الرازقي - سيارة سيدان',
    'أحمد إبراهيم - شاحنة',
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _dio.get('/api/shop-owner/orders');
      final items = _extractOrders(response.data);
      final parsed = items.map(_toOrderModel).toList();

      allOrders.assignAll(parsed);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map<String, dynamic>)
          ? (e.response?.data['message']?.toString() ?? 'فشل تحميل الطلبات')
          : 'فشل تحميل الطلبات';
      errorMessage.value = msg;
    } catch (e) {
      errorMessage.value = 'فشل تحميل الطلبات';
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _extractOrders(dynamic raw) {
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) return data.whereType<Map<String, dynamic>>().toList();
      if (data is Map<String, dynamic> && data['orders'] is List) {
        return (data['orders'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      if (raw['orders'] is List) {
        return (raw['orders'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }
    return [];
  }

  OrderModel _toOrderModel(Map<String, dynamic> json) {
    final subOrderId =
        json['action_sub_order_id'] ??
        json['sub_order_id'] ??
        json['suborder_id'] ??
        (json['sub_order'] is Map<String, dynamic>
            ? (json['sub_order'] as Map<String, dynamic>)['id']
            : null);

    final orderNumber = (json['order_number'] ?? json['id'] ?? '').toString();
    final isNumericOnly = RegExp(r'^\d+$').hasMatch(orderNumber);
    final idText = isNumericOnly && !orderNumber.endsWith('#')
        ? '$orderNumber#'
        : orderNumber;

    final statusRaw = (json['status'] ?? '').toString().toLowerCase();

    final customerMap = json['customer'] as Map<String, dynamic>?;
    final userMap =
        (customerMap != null && customerMap['user'] is Map<String, dynamic>)
        ? customerMap['user'] as Map<String, dynamic>
        : (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : null;
    final firstName = _cleanString(
      customerMap?['first_name'] ?? userMap?['first_name'],
    );
    final lastName = _cleanString(
      customerMap?['last_name'] ?? userMap?['last_name'],
    );
    final fullNameFromParts = [
      if (firstName != null) firstName,
      if (lastName != null) lastName,
    ].join(' ').trim();
    final customerName =
        _cleanString(json['customer_name']) ??
        _cleanString(json['client_name']) ??
        _cleanString(json['username']) ??
        _cleanString(customerMap?['name']) ??
        _cleanString(customerMap?['full_name']) ??
        _cleanString(customerMap?['username']) ??
        _cleanString(customerMap?['display_name']) ??
        _cleanString(customerMap?['user_name']) ??
        _cleanString(userMap?['name']) ??
        _cleanString(userMap?['full_name']) ??
        _cleanString(userMap?['username']) ??
        _cleanString(userMap?['display_name']) ??
        _cleanString(fullNameFromParts) ??
        'عميل';

    final regionName =
        (json['region_name'] ?? json['address_region_name'] ?? '').toString();

    final totalValue =
        json['total'] ?? json['total_amount'] ?? json['subtotal'] ?? 0;
    final total = totalValue is num
        ? totalValue.toDouble()
        : (double.tryParse(totalValue.toString()) ?? 0);

    final createdAt = DateTime.tryParse((json['created_at'] ?? '').toString());
    final elapsed = _timeElapsed(createdAt);
    final date = _dateLabel(createdAt);

    final driverMap = json['driver'] as Map<String, dynamic>?;
    final driverName = (json['driver_name'] ?? driverMap?['name'])?.toString();
    final driverAvatar = (json['driver_avatar'] ?? driverMap?['avatar'])
        ?.toString();

    final itemsCount = (json['item_count'] is int)
        ? json['item_count'] as int
        : (json['items_count'] is int)
        ? json['items_count'] as int
        : ((json['items'] is List) ? (json['items'] as List).length : 1);

    bool isManual = false;
    final orderTypeRaw = json['order_type']?.toString().toLowerCase();
    if (orderTypeRaw == 'manual' || orderTypeRaw == 'manual_order') {
      isManual = true;
    } else if (json['items'] is List) {
      for (var item in json['items']) {
        if (item['product_name_en'] == 'Manual Order' ||
            item['product_name_ar'] == 'طلب يدوي') {
          isManual = true;
          break;
        }
      }
    }
    final deducedOrderType = isManual ? 'manual' : (orderTypeRaw ?? 'delivery');

    return OrderModel(
      backendId: subOrderId is int
          ? subOrderId
          : int.tryParse((subOrderId ?? json['id'] ?? '').toString()),
      id: idText,
      customerName: customerName,
      price: total,
      currency: 'LYD',
      status: _statusLabel(statusRaw),
      timeElapsed: elapsed,
      itemCount: itemsCount,
      driverName: driverName,
      orderType: deducedOrderType,
      customerAddress: regionName,
      driverAvatar: driverAvatar,
      date: date,
      statusRaw: statusRaw,
    );
  }

  bool _isNewStatus(String status) {
    return status == 'new' || status == 'pending';
  }

  bool _isOngoingStatus(String status) {
    const ongoing = {
      'confirmation',
      'accepted',
      'confirmed',
      'preparing',
      'ready_for_pickup',
      'picked_up',
      'on_the_way',
      'processing',
      'assigned',
      'waiting_pickup',
    };
    return ongoing.contains(status);
  }

  bool _isCompletedStatus(String status) {
    const completed = {
      'completed',
      'delivered',
      'cancelled',
      'rejected',
      'archived',
    };
    return completed.contains(status);
  }

  String _statusLabel(String status) {
    if (_isNewStatus(status)) return 'status_new'.tr;
    if (status == 'confirmation') return 'ongoing_status_waiting_confirm'.tr;
    if (status == 'preparing' ||
        status == 'accepted' ||
        status == 'confirmed') {
      return 'ongoing_status_preparing'.tr;
    }
    if (status == 'waiting_pickup' || status == 'ready_for_pickup') {
      return 'ongoing_status_waiting_pickup'.tr;
    }
    if (_isOngoingStatus(status)) return 'ongoing_status_waiting_confirm'.tr;
    if (status == 'completed' || status == 'delivered')
      return 'status_delivered_badge'.tr;
    if (status == 'cancelled' || status == 'rejected' || status == 'archived')
      return 'status_archived'.tr;
    return status;
  }

  String _timeElapsed(DateTime? createdAt) {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'minutes_ago'.trParams({'min': '1'});
    if (diff.inMinutes < 60)
      return 'minutes_ago'.trParams({'min': '${diff.inMinutes}'});
    return 'minutes_ago'.trParams({'min': '${diff.inHours * 60}'});
  }

  String _dateLabel(DateTime? createdAt) {
    if (createdAt == null) return '';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
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

  void assignDriver(String orderId, String driver) {
    final index = allOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updated = allOrders[index].copyWith(
        driverName: driver.split(' - ').first,
      );
      allOrders[index] = updated;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
