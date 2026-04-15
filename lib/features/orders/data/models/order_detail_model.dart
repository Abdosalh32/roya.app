// lib/features/orders/data/models/order_detail_model.dart

import 'order_modification_models.dart';

class OrderDetailModel {
  final int? backendId;
  final String orderNumber;
  final String status;
  final String statusRaw;
  final String date;
  final String deliveryType;
  final String customerName;
  final String customerCity;
  final String customerPhone;
  final String? driverName;
  final String? driverPhone;
  final String? distributorDriverName;
  final String? distributorDriverPhone;
  final List<OrderProductItem> products;
  final List<SubOrderItemReview>? reviews;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const OrderDetailModel({
    this.backendId,
    this.reviews,
    required this.orderNumber,
    required this.status,
    required this.statusRaw,
    required this.date,
    required this.deliveryType,
    required this.customerName,
    required this.customerCity,
    required this.customerPhone,
    this.driverName,
    this.driverPhone,
    this.distributorDriverName,
    this.distributorDriverPhone,
    required this.products,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });
}

class OrderProductItem {
  final int? id;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final SubOrderItemReview? review;

  const OrderProductItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.review,
  });
}
