import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/features/profile/controllers/profile_controller.dart';

class WorkingHoursScreen extends StatefulWidget {
  const WorkingHoursScreen({Key? key}) : super(key: key);

  @override
  State<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  final ProfileController c = Get.find<ProfileController>();
  
  final Map<String, Map<String, dynamic>> workingHours = {
    'sun': {'open': TextEditingController(), 'close': TextEditingController(), 'isClosed': false.obs},
    'mon': {'open': TextEditingController(), 'close': TextEditingController(), 'isClosed': false.obs},
    'tue': {'open': TextEditingController(), 'close': TextEditingController(), 'isClosed': false.obs},
    'wed': {'open': TextEditingController(), 'close': TextEditingController(), 'isClosed': false.obs},
    'thu': {'open': TextEditingController(), 'close': TextEditingController(), 'isClosed': false.obs},
    'fri': {'open': TextEditingController(), 'close': TextEditingController(), 'isClosed': false.obs},
    'sat': {'open': TextEditingController(), 'close': TextEditingController(), 'isClosed': false.obs},
  };

  final Map<String, String> dayLabels = {
    'sun': 'الأحد',
    'mon': 'الاثنين',
    'tue': 'الثلاثاء',
    'wed': 'الأربعاء',
    'thu': 'الخميس',
    'fri': 'الجمعة',
    'sat': 'السبت',
  };

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final shop = c.user.value;
    if (shop != null && shop.workingDays != null) {
      for (var day in workingHours.keys) {
        final isWorkingDay = shop.workingDays!.contains(day);
        workingHours[day]!['isClosed'].value = !isWorkingDay;
        
        if (isWorkingDay && shop.openTime != null && shop.closeTime != null) {
          workingHours[day]!['open'].text = shop.openTime!;
          workingHours[day]!['close'].text = shop.closeTime!;
        }
      }
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
      // Build working hours array for backend
      final workingHoursArray = [];
      for (var day in workingHours.keys) {
        final isClosed = workingHours[day]!['isClosed'].value;
        final openTime = workingHours[day]!['open'].text;
        final closeTime = workingHours[day]!['close'].text;
        
        workingHoursArray.add({
          'day_of_week': day,
          'open_time': isClosed || openTime.isEmpty ? null : (openTime.length > 5 ? openTime.substring(0, 5) : openTime),
          'close_time': isClosed || closeTime.isEmpty ? null : (closeTime.length > 5 ? closeTime.substring(0, 5) : closeTime),
          'is_closed': isClosed,
        });
      }

      // Get working days (days that are not closed)
      final workingDays = workingHours.entries
          .where((e) => !e.value['isClosed'].value)
          .map((e) => e.key)
          .toList();

      final shop = c.user.value;
      final shopOpenTime = shop?.openTime;
      final shopCloseTime = shop?.closeTime;

      final payload = {
        'name_ar': shop?.nameAr ?? '',
        'name_en': shop?.nameEn ?? '',
        'open_time': shopOpenTime != null && shopOpenTime.isNotEmpty 
            ? (shopOpenTime.length > 5 ? shopOpenTime.substring(0, 5) : shopOpenTime)
            : '',
        'close_time': shopCloseTime != null && shopCloseTime.isNotEmpty 
            ? (shopCloseTime.length > 5 ? shopCloseTime.substring(0, 5) : shopCloseTime)
            : '',
        'working_days': workingDays,
        'working_hours': workingHoursArray,
      };

      final success = await c.updateProfile(payload: payload);

      if (mounted) {
        if (success) {
          Get.snackbar(
            'تم بنجاح',
            'تم حفظ ساعات العمل بنجاح',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          Navigator.of(context).pop(true);
        } else {
          Get.snackbar(
            'خطأ',
            c.errorMessage.value.isNotEmpty
                ? c.errorMessage.value
                : 'فشل في حفظ ساعات العمل',
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
          'ساعات العمل',
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
                  children: workingHours.entries.map((entry) {
                    return _buildDayCard(entry.key, entry.value);
                  }).toList(),
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(String day, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dayLabels[day]!,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    data['isClosed'].value ? 'مغلق' : 'مفتوح',
                    style: TextStyle(
                      color: data['isClosed'].value ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: !data['isClosed'].value,
                    onChanged: (value) {
                      data['isClosed'].value = !value;
                      setState(() {});
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
          if (!data['isClosed'].value) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(data['open']),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: data['open'],
                        decoration: const InputDecoration(
                          labelText: 'من',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('إلى', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectTime(data['close']),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: data['close'],
                        decoration: const InputDecoration(
                          labelText: 'إلى',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
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
                'حفظ ساعات العمل',
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
    for (var day in workingHours.values) {
      day['open'].dispose();
      day['close'].dispose();
    }
    super.dispose();
  }
}
