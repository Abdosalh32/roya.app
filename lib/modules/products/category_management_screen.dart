import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/modules/products/controller.dart';

class CategoryManagementScreen extends StatelessWidget {
  CategoryManagementScreen({Key? key}) : super(key: key);
  final ProductsController c = Get.find();

  final TextEditingController _nameAr = TextEditingController();
  final TextEditingController _nameEn = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التصنيفات'),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAdd(context),
        backgroundColor: AppColors.primary,
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
                          _showEdit(context, cat.id, cat.nameAr, cat.nameEn),
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
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameAr,
              decoration: const InputDecoration(labelText: 'الاسم (عربي)'),
            ),
            TextField(
              controller: _nameEn,
              decoration: const InputDecoration(labelText: 'Name (EN)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await c.createCategory(_nameAr.text, _nameEn.text);
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEdit(BuildContext context, int id, String nameAr, String nameEn) {
    _nameAr.text = nameAr;
    _nameEn.text = nameEn;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameAr,
              decoration: const InputDecoration(labelText: 'الاسم (عربي)'),
            ),
            TextField(
              controller: _nameEn,
              decoration: const InputDecoration(labelText: 'Name (EN)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await c.updateCategory(id, _nameAr.text, _nameEn.text, true);
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
