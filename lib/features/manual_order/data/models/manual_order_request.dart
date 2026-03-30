import 'package:dio/dio.dart';

class ManualOrderRequest {
  final String clientName;
  final String clientPhone;
  final double totalPrice;
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
      'client_name': clientName,
      'client_phone': clientPhone,
      'total_price': totalPrice,
      'package_type': packageType,
      'city': city,
      'address': address,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (deliveryNotes != null && deliveryNotes!.isNotEmpty)
        'delivery_notes': deliveryNotes,
    });

    if (imagePath != null && imagePath!.isNotEmpty) {
      formData.files.add(
        MapEntry('product_image', await MultipartFile.fromFile(imagePath!)),
      );
    }

    return formData;
  }
}
