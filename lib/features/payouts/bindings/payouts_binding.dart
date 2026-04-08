import 'package:get/get.dart';
import '../controllers/payouts_controller.dart';
import '../data/repositories/payouts_repository.dart';

class PayoutsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PayoutsRepository>(() => PayoutsRepository());
    Get.lazyPut<PayoutsController>(() => PayoutsController());
  }
}
