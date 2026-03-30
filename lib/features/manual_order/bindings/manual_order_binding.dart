import 'package:get/get.dart';
import '../controllers/manual_order_controller.dart';
import '../data/repositories/manual_order_repository.dart';

class ManualOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManualOrderRepository>(() => ManualOrderRepository());
    Get.lazyPut<ManualOrderController>(() => ManualOrderController());
  }
}
