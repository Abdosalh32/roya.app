// lib/features/orders/data/models/order_detail_model.dart

class OrderDetailModel {
  final String orderNumber;
  final String status;
  final String date;
  final String deliveryType;
  final String customerName;
  final String customerCity;
  final String customerPhone;
  final List<OrderProductItem> products;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double total;

  const OrderDetailModel({
    required this.orderNumber,
    required this.status,
    required this.date,
    required this.deliveryType,
    required this.customerName,
    required this.customerCity,
    required this.customerPhone,
    required this.products,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });
}

class OrderProductItem {
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;

  const OrderProductItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });
}
