import 'package:get/get.dart';

import '../../../../core/services/order_service.dart';
import '../../../../data/models/region_model.dart';
import '../models/manual_order_request.dart';

class ManualOrderRepository extends GetxService {
  final _orderService = Get.find<OrderService>();

  Future<void> createManualOrder(ManualOrderRequest request) async {
    final formData = await request.toFormData();
    await _orderService.createManualOrder(formData);
  }

  Future<List<RegionModel>> fetchRegions() async {
    return await _orderService.fetchRegions();
  }
}
