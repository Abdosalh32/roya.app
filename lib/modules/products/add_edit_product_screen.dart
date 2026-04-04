import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roya/core/theme/app_colors.dart';
import 'package:roya/data/models/product_model.dart';
import 'package:roya/modules/products/controller.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductsController c = Get.find();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameAr = TextEditingController();
  final TextEditingController nameEn = TextEditingController();
  final TextEditingController descAr = TextEditingController();
  final TextEditingController descEn = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController comparePrice = TextEditingController();
  bool isActive = true;
  int? categoryId;

  final List<XFile> newImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      nameAr.text = p.nameAr;
      nameEn.text = p.nameEn;
      descAr.text = p.descriptionAr ?? '';
      descEn.text = p.descriptionEn ?? '';
      price.text = p.price.toString();
      comparePrice.text = p.comparePrice?.toString() ?? '';
      isActive = p.isActive;
      categoryId = p.categoryId;
    }
  }

  Future<void> pickImage() async {
    if (newImages.length >= 5) return;
    final res = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (res != null) setState(() => newImages.add(res));
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'name_ar': nameAr.text,
      'name_en': nameEn.text,
      'description_ar': descAr.text.isEmpty ? null : descAr.text,
      'description_en': descEn.text.isEmpty ? null : descEn.text,
      'price': double.tryParse(price.text) ?? 0.0,
      'compare_price': comparePrice.text.isEmpty
          ? null
          : double.tryParse(comparePrice.text),
      'is_active': isActive,
      'category_id': categoryId,
    };

    if (widget.product == null) {
      await c.createProduct(payload, newImages);
    } else {
      await c.updateProduct(widget.product!.id, payload, newImages);
    }

    Navigator.of(context).pop();
  }

  List<Widget> _buildExistingImages(Product? p) {
    if (p == null) return [];
    return p.images
        .map(
          (img) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: img.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: implement server-side delete
                    },
                    child: Container(
                      color: Colors.black45,
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'إضافة منتج' : 'تعديل المنتج'),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Icon(Icons.add)),
                        ),
                      ),
                      ...newImages.map(
                        (x) => Stack(
                          children: [
                            Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(x.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 4,
                              top: 4,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => newImages.remove(x)),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black54,
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ..._buildExistingImages(widget.product),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameAr,
                  decoration: const InputDecoration(labelText: 'الاسم (عربي)'),
                  textDirection: TextDirection.rtl,
                  validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameEn,
                  decoration: const InputDecoration(labelText: 'Name (EN)'),
                  textDirection: TextDirection.ltr,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descAr,
                  decoration: const InputDecoration(labelText: 'الوصف (عربي)'),
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descEn,
                  decoration: const InputDecoration(
                    labelText: 'Description (EN)',
                  ),
                  maxLines: 3,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  value: categoryId,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('بدون تصنيف'),
                    ),
                    ...c.categories
                        .map(
                          (cat) => DropdownMenuItem<int?>(
                            value: cat.id,
                            child: Text(cat.nameAr),
                          ),
                        )
                        .toList(),
                  ],
                  onChanged: (v) => setState(() => categoryId = v),
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: price,
                  decoration: const InputDecoration(labelText: 'السعر (LYD)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: comparePrice,
                  decoration: const InputDecoration(
                    labelText: 'سعر قبل الخصم (اختياري)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('نشط'),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('حفظ المنتج'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
