import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/modules/products/controller.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final ProductsController c = Get.find();
  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _nameEn = TextEditingController();

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التصنيفات'),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
        onPressed: () => _showAdd(context),
      ),
      body: Obx(() {
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: c.categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final cat = c.categories[idx];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(cat.nameAr),
                subtitle: Text(cat.nameEn),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: cat.isActive,
                      onChanged: (v) =>
                          c.updateCategory(cat.id, cat.nameAr, cat.nameEn, v),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showEdit(context, cat.id, cat.nameAr, cat.nameEn, cat.isActive),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('حذف'),
                            content: const Text('هل تريد حذف هذا التصنيف؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('لا'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('نعم'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) c.deleteCategory(cat.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAdd(BuildContext context) {
    _nameAr.clear();
    _nameEn.clear();
    bool isActive = true;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'إضافة تصنيف جديد',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameAr,
                  decoration: const InputDecoration(
                    labelText: 'الاسم (عربي)',
                    border: OutlineInputBorder(),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameEn,
                  decoration: const InputDecoration(
                    labelText: 'Name (EN)',
                    border: OutlineInputBorder(),
                  ),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('نشط'),
                    const SizedBox(width: 8),
                    Switch(
                      value: isActive,
                      onChanged: (value) {
                        setState(() => isActive = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_nameAr.text.isEmpty || _nameEn.text.isEmpty) {
                        Get.snackbar(
                          'خطأ',
                          'يرجى ملء جميع الحقول',
                          backgroundColor: const Color(0xFFD32F2F),
                          colorText: const Color(0xFFFFFFFF),
                        );
                        return;
                      }
                      await c.createCategory(_nameAr.text, _nameEn.text, isActive: isActive);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('حفظ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEdit(BuildContext context, int id, String nameAr, String nameEn, bool currentIsActive) {
    _nameAr.text = nameAr;
    _nameEn.text = nameEn;
    bool isActive = currentIsActive;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تعديل التصنيف',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameAr,
                  decoration: const InputDecoration(
                    labelText: 'الاسم (عربي)',
                    border: OutlineInputBorder(),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameEn,
                  decoration: const InputDecoration(
                    labelText: 'Name (EN)',
                    border: OutlineInputBorder(),
                  ),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('نشط'),
                    const SizedBox(width: 8),
                    Switch(
                      value: isActive,
                      onChanged: (value) {
                        setState(() => isActive = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_nameAr.text.isEmpty || _nameEn.text.isEmpty) {
                        Get.snackbar(
                          'خطأ',
                          'يرجى ملء جميع الحقول',
                          backgroundColor: const Color(0xFFD32F2F),
                          colorText: const Color(0xFFFFFFFF),
                        );
                        return;
                      }
                      await c.updateCategory(id, _nameAr.text, _nameEn.text, isActive);
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
