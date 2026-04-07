import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/region_model.dart';
import '../data/models/manual_order_request.dart';
import '../data/repositories/manual_order_repository.dart';

class ManualOrderController extends GetxController {
  final ManualOrderRepository _repository = Get.find<ManualOrderRepository>();

  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final clientNameCtrl = TextEditingController();
  final clientPhoneCtrl = TextEditingController();
  final totalPriceCtrl = TextEditingController();
  final deliveryFeeCtrl = TextEditingController(text: '5.0');
  final quantityCtrl = TextEditingController(text: '1');
  final descriptionCtrl = TextEditingController();
  final addressDetailsCtrl = TextEditingController();
  final deliveryNotesCtrl = TextEditingController();

  // Reactive State
  final isLoading = false.obs;
  final isLoadingRegions = false.obs;
  final selectedPackageType = 'مغلف'.obs;

  final regions = <RegionModel>[].obs;
  final selectedRegionId = Rxn<int>();

  final imagePath = ''.obs;

  // Computed State
  final deliveryFee = 5.00.obs;
  final subtotal = 0.0.obs;
  double get totalCharge => subtotal.value + deliveryFee.value;

  final List<String> packageTypes = ['مغلف', 'صندوق', 'كيس', 'عادي'];

  @override
  void onInit() {
    super.onInit();
    _fetchRegions();
    totalPriceCtrl.addListener(() {
      final value = double.tryParse(totalPriceCtrl.text) ?? 0.0;
      subtotal.value = value;
    });
    deliveryFeeCtrl.addListener(() {
      final value = double.tryParse(deliveryFeeCtrl.text) ?? 0.0;
      deliveryFee.value = value;
    });
  }

  Future<void> _fetchRegions() async {
    try {
      isLoadingRegions.value = true;
      final fetchedRegions = await _repository.fetchRegions();
      regions.value = fetchedRegions;
      if (regions.isNotEmpty) {
        selectedRegionId.value = regions.first.id;
      }
    } catch (e) {
      debugPrint('Failed to load regions: $e');
    } finally {
      isLoadingRegions.value = false;
    }
  }

  @override
  void onClose() {
    clientNameCtrl.dispose();
    clientPhoneCtrl.dispose();
    totalPriceCtrl.dispose();
    deliveryFeeCtrl.dispose();
    quantityCtrl.dispose();
    descriptionCtrl.dispose();
    addressDetailsCtrl.dispose();
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

    if (selectedRegionId.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المنطقة'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    try {
      isLoading.value = true;

      final request = ManualOrderRequest(
        clientName: clientNameCtrl.text.trim(),
        clientPhone: clientPhoneCtrl.text.trim(),
        totalPrice: subtotal.value,
        deliveryFee: deliveryFee.value,
        quantity: int.tryParse(quantityCtrl.text.trim()) ?? 1,
        addressRegionId: selectedRegionId.value!,
        packageType: selectedPackageType.value,
        description: descriptionCtrl.text.trim(),
        imagePath: imagePath.value.isEmpty ? null : imagePath.value,
        address: addressDetailsCtrl.text.isNotEmpty
            ? addressDetailsCtrl.text.trim()
            : 'لا يوجد تفاصيل إضافية',
        city: 'طرابلس',
        deliveryNotes: deliveryNotesCtrl.text.trim(),
      );

      await _repository.createManualOrder(request);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الطلب بنجاح ✓'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
