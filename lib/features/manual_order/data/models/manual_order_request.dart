import 'package:dio/dio.dart';

class ManualOrderRequest {
  final String clientName;
  final String clientPhone;
  final double totalPrice;
  final double deliveryFee;
  final int quantity;
  final int addressRegionId;
  final String packageType;
  final String? description;
  final String? imagePath;
  final String address;
  final String city;
  final String? deliveryNotes;

  ManualOrderRequest({
    required this.clientName,
    required this.clientPhone,
    required this.totalPrice,
    required this.deliveryFee,
    required this.quantity,
    required this.addressRegionId,
    required this.packageType,
    this.description,
    this.imagePath,
    required this.address,
    required this.city,
    this.deliveryNotes,
  });

  /// Converting the generic object data to FormData
  /// handling potential image uploads using MultipartFile.
  Future<FormData> toFormData() async {
    final formData = FormData.fromMap({
      'customer_name': clientName,
      'customer_phone': clientPhone,
      'unit_price': totalPrice,
      'delivery_fee': deliveryFee,
      'quantity': quantity,
      'address_region_id': addressRegionId,
      'address_details': '$address - $city',
      if (description != null && description!.isNotEmpty)
        'product_description': description,
      if (deliveryNotes != null && deliveryNotes!.isNotEmpty)
        'notes': deliveryNotes,
    });

    if (imagePath != null && imagePath!.isNotEmpty) {
      formData.files.add(
        MapEntry('product_image', await MultipartFile.fromFile(imagePath!)),
      );
    }

    return formData;
  }
}
