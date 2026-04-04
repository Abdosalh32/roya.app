import 'package:get/get.dart';
import 'package:roya/core/network/api_client.dart';
import 'package:roya/data/repositories/products_repository.dart';
import 'package:roya/modules/products/controller.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    // DioClient (GetxService) is registered in InitialBinding as Get.putAsync(() => DioClient().init())
    final dioClient = Get.find<DioClient>();
    final dio = dioClient.dio;
    Get.lazyPut<ProductsRepository>(() => ProductsRepository(dio));
    Get.lazyPut<ProductsController>(() => ProductsController(Get.find()));
  }
}
