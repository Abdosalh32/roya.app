import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/services/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync(() => ApiClient().init());
    Get.putAsync(() => AuthService().init());
  }
}
