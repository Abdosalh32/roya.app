import 'package:get/get.dart';
import '../../../../core/services/order_service.dart';
import '../models/manual_order_request.dart';

class ManualOrderRepository extends GetxService {
  final _orderService = Get.find<OrderService>();

  Future<void> createManualOrder(ManualOrderRequest request) async {
    // In actual implementation, we'd use request.toFormData() to build multipart payload.
    // For mock implementation, we pass a simple key-value map.
    final dataMap = {
      'client_name': request.clientName,
      'client_phone': request.clientPhone,
      'total_price': request.totalPrice,
      'address': request.address,
      'has_image': request.imagePath != null,
    };

    await _orderService.createManualOrder(dataMap);
  }
}
