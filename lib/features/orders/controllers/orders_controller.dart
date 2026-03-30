import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OrderModel {
  final String id;
  final String customerName;
  final double price;
  final String currency;
  final String status;
  final String timeElapsed;
  final int itemCount;
  final String? driverName;
  final String orderType; // 'delivery' | 'pickup'
  
  final String? customerAddress;
  final String? driverAvatar;
  final String? date;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.price,
    required this.currency,
    required this.status,
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
      id: id,
      customerName: customerName,
      price: price,
      currency: currency,
      status: status ?? this.status,
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

class OrdersController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final isLoading = false.obs;

  final RxList<OrderModel> newOrders = <OrderModel>[].obs;
  final RxList<OrderModel> ongoingOrders = <OrderModel>[].obs;
  final RxList<OrderModel> completedOrders = <OrderModel>[].obs;
  
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
    _loadMockData();
  }

  void _loadMockData() {
    newOrders.value = [
      OrderModel(
        id: 'RY177016#',
        customerName: 'يوسف أحمد',
        price: 214.98,
        currency: 'LYD',
        status: 'status_new'.tr,
        timeElapsed: 'minutes_ago'.trParams({'min': '5'}),
        itemCount: 2,
      ),
      OrderModel(
        id: 'RY177017#',
        customerName: 'سارة محمد',
        price: 150.00,
        currency: 'LYD',
        status: 'status_new'.tr,
        timeElapsed: 'minutes_ago'.trParams({'min': '12'}),
        itemCount: 1,
      ),
      OrderModel(
        id: 'RY177018#',
        customerName: 'عبدالله العلي',
        price: 342.50,
        currency: 'LYD',
        status: 'status_new'.tr,
        timeElapsed: 'minutes_ago'.trParams({'min': '25'}),
        itemCount: 3,
      ),
      OrderModel(
        id: 'RY177019#',
        customerName: 'مريم صالح',
        price: 89.00,
        currency: 'LYD',
        status: 'status_new'.tr,
        timeElapsed: 'minutes_ago'.trParams({'min': '40'}),
        itemCount: 1,
      ),
    ];

    ongoingOrders.value = [
      OrderModel(
        id: 'RY177484#',
        customerName: 'جون كاستمر',
        price: 279.98,
        currency: 'LYD',
        status: 'ongoing_status_waiting_pickup'.tr,
        timeElapsed: 'minutes_ago'.trParams({'min': '1'}),
        itemCount: 2,
        driverName: 'مايك درايفر',
        orderType: 'delivery',
      ),
      OrderModel(
        id: 'RY177490#',
        customerName: 'سارة أحمد',
        price: 450.00,
        currency: 'LYD',
        status: 'ongoing_status_preparing'.tr,
        timeElapsed: 'minutes_ago'.trParams({'min': '10'}),
        itemCount: 0,
        driverName: null,
        orderType: 'delivery',
      ),
      OrderModel(
        id: 'RY177502#',
        customerName: 'محمد علي',
        price: 120.50,
        currency: 'LYD',
        status: 'ongoing_status_waiting_confirm'.tr,
        timeElapsed: 'minutes_ago'.trParams({'min': '40'}),
        itemCount: 1,
        driverName: null,
        orderType: 'delivery',
      ),
    ];

    completedOrders.value = [
      // Today
      OrderModel(
        id: 'RY56366484#',
        customerName: 'سارة أحمد',
        price: 145.00,
        currency: 'د.ل',
        status: 'status_delivered_badge'.tr,
        timeElapsed: '',
        date: '24 مايو 2026',
        customerAddress: 'حي الأندلس، طرابلس',
        driverName: 'أحمد المحمودي',
        driverAvatar: 'https://i.pravatar.cc/150?img=11',
      ),
      OrderModel(
        id: 'RY56366490#',
        customerName: 'محمد العبيدي',
        price: 85.50,
        currency: 'د.ل',
        status: 'status_delivered_badge'.tr,
        timeElapsed: '',
        date: '24 مايو 2026',
        customerAddress: 'سوق الجمعة، طرابلس',
        driverName: 'إبراهيم صالح',
        driverAvatar: 'https://i.pravatar.cc/150?img=12',
      ),
      // Last Week
      OrderModel(
        id: 'RY56366512#',
        customerName: 'نورا سالم',
        price: 210.00,
        currency: 'د.ل',
        status: 'status_delivered_badge'.tr,
        timeElapsed: '',
        date: '23 مايو 2026',
        customerAddress: 'حي دمشق، طرابلس',
        driverName: 'عمر الفيتوري',
        driverAvatar: 'https://i.pravatar.cc/150?img=13',
      ),
      OrderModel(
        id: 'RY56366100#',
        customerName: 'خالد منصور',
        price: 190.00,
        currency: 'د.ل',
        status: 'status_archived'.tr,
        timeElapsed: '',
        date: '20 مايو 2026',
        customerAddress: 'جنزور',
        driverName: 'سالم الكوني',
        driverAvatar: 'https://i.pravatar.cc/150?img=14',
      ),
    ];
  }

  void assignDriver(String orderId, String driver) {
    final index = ongoingOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updated = ongoingOrders[index].copyWith(driverName: driver.split(' - ').first);
      ongoingOrders[index] = updated;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
