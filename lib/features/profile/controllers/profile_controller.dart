import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roya/features/auth/data/models/login_model.dart';
import 'package:roya/features/profile/data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository repository;

  ProfileController(this.repository);

  final Rx<ShopModel?> user = Rx<ShopModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final profileData = await repository.getProfile();
      user.value = profileData;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error fetching profile: \$e');
    } finally {
      isLoading.value = false;
    }
  }
}
