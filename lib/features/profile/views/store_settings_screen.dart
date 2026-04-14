import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/features/profile/controllers/profile_controller.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final ProfileController c = Get.find<ProfileController>();
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final TextEditingController nameArController = TextEditingController();
  final TextEditingController nameEnController = TextEditingController();
  final TextEditingController descriptionArController = TextEditingController();
  final TextEditingController descriptionEnController = TextEditingController();
  final TextEditingController openTimeController = TextEditingController();
  final TextEditingController closeTimeController = TextEditingController();

  // Images
  XFile? newLogoFile;
  XFile? newBannerFile;

  final Map<String, String> dayLabels = {
    'mon': 'الاثنين',
    'tue': 'الثلاثاء',
    'wed': 'الأربعاء',
    'thu': 'الخميس',
    'fri': 'الجمعة',
    'sat': 'السبت',
    'sun': 'الأحد',
  };

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final shop = c.user.value;
    if (shop != null) {
      nameArController.text = shop.nameAr ?? '';
      nameEnController.text = shop.nameEn ?? '';
      descriptionArController.text = shop.descriptionAr ?? '';
      descriptionEnController.text = shop.descriptionEn ?? '';
      
      // Load times and strip seconds if present (backend returns "HH:MM:SS", we need "HH:MM")
      final openTime = shop.openTime ?? '';
      final closeTime = shop.closeTime ?? '';
      openTimeController.text = openTime.isNotEmpty 
          ? (openTime.length > 5 ? openTime.substring(0, 5) : openTime)
          : '';
      closeTimeController.text = closeTime.isNotEmpty 
          ? (closeTime.length > 5 ? closeTime.substring(0, 5) : closeTime)
          : '';
    }
  }

  Future<void> _pickLogo() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 500,
    );
    if (file != null) {
      setState(() => newLogoFile = file);
    }
  }

  Future<void> _pickBanner() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1000,
    );
    if (file != null) {
      setState(() => newBannerFile = file);
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      setState(() => controller.text = formatted);
    }
  }

  Future<void> _save() async {
    setState(() => isLoading = true);

    try {
      final payload = {
        'name_ar': nameArController.text.trim(),
        'name_en': nameEnController.text.trim(),
        'description_ar': descriptionArController.text.trim().isEmpty
            ? null
            : descriptionArController.text.trim(),
        'description_en': descriptionEnController.text.trim().isEmpty
            ? null
            : descriptionEnController.text.trim(),
        'open_time': openTimeController.text.trim().isEmpty
            ? null
            : openTimeController.text.trim().substring(0, 5), // "HH:MM" only, remove seconds
        'close_time': closeTimeController.text.trim().isEmpty
            ? null
            : closeTimeController.text.trim().substring(0, 5), // "HH:MM" only, remove seconds
      };

      final success = await c.updateProfile(
        payload: payload,
        logoFile: newLogoFile != null ? File(newLogoFile!.path) : null,
        bannerFile: newBannerFile != null ? File(newBannerFile!.path) : null,
      );

      if (mounted) {
        if (success) {
          Get.snackbar(
            'تم بنجاح',
            'تم حفظ إعدادات المتجر بنجاح',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          Navigator.of(context).pop(true);
        } else {
          Get.snackbar(
            'خطأ',
            c.errorMessage.value.isNotEmpty
                ? c.errorMessage.value
                : 'فشل في حفظ الإعدادات',
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'خطأ',
          'حدث خطأ: ${e.toString()}',
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'إعدادات المتجر',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBannerSection(),
                    const SizedBox(height: 20),
                    _buildLogoSection(),
                    const SizedBox(height: 20),
                    _buildNameSection(),
                    const SizedBox(height: 20),
                    _buildDescriptionSection(),
                    const SizedBox(height: 20),
                    _buildWorkingHoursSection(),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    final shop = c.user.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صورة الغلاف',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickBanner,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: newBannerFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(newBannerFile!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : (shop?.bannerUrl != null && shop!.bannerUrl!.isNotEmpty)
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: shop.bannerUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'اضغط لإضافة صورة الغلاف',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    final shop = c.user.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'شعار المتجر',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            GestureDetector(
              onTap: _pickLogo,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: newLogoFile != null
                    ? ClipOval(
                        child: Image.file(
                          File(newLogoFile!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : (shop?.logo != null && shop!.logo!.isNotEmpty)
                        ? Stack(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: shop.logo!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Icon(
                            Icons.add_a_photo,
                            size: 30,
                            color: Colors.grey[600],
                          ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'اضغط على الشعار لتغييره. يُفضل استخدام صورة مربعة.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontFamily: 'Cairo',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اسم المتجر',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nameArController,
          decoration: const InputDecoration(
            labelText: 'الاسم (عربي)',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nameEnController,
          decoration: const InputDecoration(
            labelText: 'Name (English)',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'وصف المتجر (اختياري)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descriptionArController,
          decoration: const InputDecoration(
            labelText: 'الوصف (عربي)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descriptionEnController,
          decoration: const InputDecoration(
            labelText: 'Description (English)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildWorkingHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ساعات العمل',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(openTimeController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: openTimeController,
                    decoration: const InputDecoration(
                      labelText: 'من (وقت الفتح)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('إلى', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(closeTimeController),
                child: AbsorbPointer(
                  child: TextField(
                    controller: closeTimeController,
                    decoration: const InputDecoration(
                      labelText: 'إلى (وقت الإغلاق)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'حفظ الإعدادات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    descriptionArController.dispose();
    descriptionEnController.dispose();
    openTimeController.dispose();
    closeTimeController.dispose();
    super.dispose();
  }
}
