import 'package:get/get.dart';
import 'package:roya/features/profile/controllers/profile_controller.dart';
import 'package:roya/features/profile/data/repositories/profile_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileRepository());
    Get.lazyPut(() => ProfileController(Get.find<ProfileRepository>()));
  }
}
