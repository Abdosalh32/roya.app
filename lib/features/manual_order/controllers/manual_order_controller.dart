import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/manual_order_request.dart';
import '../data/repositories/manual_order_repository.dart';
import '../../../../core/theme/app_colors.dart';

class ManualOrderController extends GetxController {
  final ManualOrderRepository _repository = Get.find<ManualOrderRepository>();

  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final clientNameCtrl = TextEditingController();
  final clientPhoneCtrl = TextEditingController();
  final totalPriceCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final deliveryNotesCtrl = TextEditingController();

  // Reactive State
  final isLoading = false.obs;
  final selectedPackageType = 'مغلف'.obs;
  final selectedDistrict = 'وسط المدينة'.obs;
  final imagePath = ''.obs;

  // Computed State
  final deliveryFee = 5.00;
  final subtotal = 0.0.obs;
  double get totalCharge => subtotal.value + deliveryFee;

  final List<String> packageTypes = ['مغلف', 'صندوق', 'كيس', 'عادي'];

  final List<String> districts = [
    'وسط المدينة',
    'أبو سليم',
    'عين زارة',
    'طريق المطار',
    'السياحية',
    'الأندلس',
    'الفرناج',
    'تاجوراء',
    'قرجي',
    'صلاح الدين',
    'حي الأندلس',
    'باب بن غشير',
  ];

  @override
  void onInit() {
    super.onInit();
    totalPriceCtrl.addListener(() {
      final value = double.tryParse(totalPriceCtrl.text) ?? 0.0;
      subtotal.value = value;
    });
  }

  @override
  void onClose() {
    clientNameCtrl.dispose();
    clientPhoneCtrl.dispose();
    totalPriceCtrl.dispose();
    descriptionCtrl.dispose();
    deliveryNotesCtrl.dispose();
    super.onClose();
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      imagePath.value = pickedFile.path;
    }
  }

  void removeImage() {
    imagePath.value = '';
  }

  Future<void> submitOrder(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final request = ManualOrderRequest(
        clientName: clientNameCtrl.text.trim(),
        clientPhone: clientPhoneCtrl.text.trim(),
        totalPrice: subtotal.value,
        packageType: selectedPackageType.value,
        description: descriptionCtrl.text.trim(),
        imagePath: imagePath.value.isEmpty ? null : imagePath.value,
        address: selectedDistrict.value,
        city: 'طرابلس',
        deliveryNotes: deliveryNotesCtrl.text.trim(),
      );

      await _repository.createManualOrder(request);

      Get.snackbar(
        'نجاح',
        'تم إنشاء الطلب بنجاح ✓',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );

      // Navigate back
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        e.toString(),
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
