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
  final TextEditingController quantity = TextEditingController();
  int? categoryId;

  final List<XFile> newImages = [];
  
  // Variant types management
  final List<Map<String, dynamic>> variantTypesData = [];
  // Each item in variantTypesData: {
  //   'nameAr': TextEditingController,
  //   'nameEn': TextEditingController,
  //   'options': List<{
  //     'valueAr': TextEditingController,
  //     'valueEn': TextEditingController,
  //     'extraPrice': TextEditingController,
  //   }>
  // }

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
      quantity.text = p.quantity?.toString() ?? '';
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

  void _showAddCategoryDialog() {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    bool isActiveCategory = true;

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
                      value: isActiveCategory,
                      onChanged: (value) {
                        setState(() => isActiveCategory = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (nameArController.text.isEmpty || nameEnController.text.isEmpty) {
                        Get.snackbar(
                          'خطأ',
                          'يرجى ملء جميع الحقول',
                          backgroundColor: const Color(0xFFD32F2F),
                          colorText: const Color(0xFFFFFFFF),
                        );
                        return;
                      }

                      // Get current categories count before adding
                      final prevCount = c.categories.length;

                      await c.createCategory(
                        nameArController.text,
                        nameEnController.text,
                        isActive: isActiveCategory,
                      );

                      // Auto-select the newly added category
                      if (c.categories.length > prevCount) {
                        final newCategory = c.categories.last;
                        if (mounted) {
                          setState(() => categoryId = newCategory.id);
                          Navigator.pop(context);
                        }
                      } else if (mounted) {
                        Navigator.pop(context);
                      }
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

  void _addVariantType() {
    setState(() {
      variantTypesData.add({
        'nameAr': TextEditingController(),
        'nameEn': TextEditingController(),
        'options': <Map<String, dynamic>>[],
      });
    });
  }

  void _removeVariantType(int index) {
    setState(() {
      variantTypesData[index]['nameAr'].dispose();
      variantTypesData[index]['nameEn'].dispose();
      for (var option in variantTypesData[index]['options']) {
        option['valueAr'].dispose();
        option['valueEn'].dispose();
        option['extraPrice'].dispose();
      }
      variantTypesData.removeAt(index);
    });
  }

  void _addOptionToVariantType(int typeIndex) {
    setState(() {
      variantTypesData[typeIndex]['options'].add({
        'valueAr': TextEditingController(),
        'valueEn': TextEditingController(),
        'extraPrice': TextEditingController(text: '0'),
      });
    });
  }

  void _removeOptionFromVariantType(int typeIndex, int optionIndex) {
    setState(() {
      variantTypesData[typeIndex]['options'][optionIndex]['valueAr'].dispose();
      variantTypesData[typeIndex]['options'][optionIndex]['valueEn'].dispose();
      variantTypesData[typeIndex]['options'][optionIndex]['extraPrice'].dispose();
      variantTypesData[typeIndex]['options'].removeAt(optionIndex);
    });
  }

  Widget _buildVariantTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'خيارات المنتج (Variants)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addVariantType,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('إضافة نوع'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (variantTypesData.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                'لا توجد خيارات بعد. اضغط على "إضافة نوع" للبدء.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ...variantTypesData.asMap().entries.map((entry) {
          final typeIndex = entry.key;
          final typeData = entry.value;
          return _buildVariantTypeCard(typeIndex, typeData);
        }).toList(),
      ],
    );
  }

  Widget _buildVariantTypeCard(int typeIndex, Map<String, dynamic> typeData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
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
                  'نوع ${typeIndex + 1}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeVariantType(typeIndex),
                tooltip: 'حذف النوع',
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: typeData['nameAr'],
            decoration: const InputDecoration(
              labelText: 'الاسم (عربي)',
              hintText: 'مثال: المقاس، اللون',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: typeData['nameEn'],
            decoration: const InputDecoration(
              labelText: 'Name (EN)',
              hintText: 'e.g., Size, Color',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'الخيارات:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _addOptionToVariantType(typeIndex),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة خيار'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...typeData['options'].asMap().entries.map((optionEntry) {
            final optionIndex = optionEntry.key;
            final optionData = optionEntry.value;
            return _buildOptionRow(typeIndex, optionIndex, optionData);
          }).toList(),
          if (typeData['options'].isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'لا توجد خيارات. اضغط "إضافة خيار" للبدء.',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(int typeIndex, int optionIndex, Map<String, dynamic> optionData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: optionData['valueAr'],
                  decoration: const InputDecoration(
                    labelText: 'القيمة (عربي)',
                    hintText: 'مثال: كبير، أحمر',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: optionData['valueEn'],
                  decoration: const InputDecoration(
                    labelText: 'Value (EN)',
                    hintText: 'e.g., Large, Red',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: optionData['extraPrice'],
                  decoration: const InputDecoration(
                    labelText: 'سعر إضافي',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _removeOptionFromVariantType(typeIndex, optionIndex),
                tooltip: 'حذف الخيار',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    // Parse quantity
    final parsedQuantity = quantity.text.isEmpty ? null : int.tryParse(quantity.text);

    // Auto-deactivate if quantity is 0 or null
    final shouldActivate = parsedQuantity != null && parsedQuantity > 0;

    final payload = {
      'name_ar': nameAr.text,
      'name_en': nameEn.text,
      'description_ar': descAr.text.isEmpty ? null : descAr.text,
      'description_en': descEn.text.isEmpty ? null : descEn.text,
      'price': double.tryParse(price.text) ?? 0.0,
      'compare_price': comparePrice.text.isEmpty
          ? null
          : double.tryParse(comparePrice.text),
      'quantity': parsedQuantity,
      'is_active': shouldActivate, // Auto-set based on quantity
      'category_id': categoryId,
    };

    try {
      if (widget.product == null) {
        // Create new product
        final createdProduct = await c.createProduct(payload, newImages);
        
        // If product was created and we have variant types, create them
        if (createdProduct != null && variantTypesData.isNotEmpty) {
          await _createVariantTypesForProduct(createdProduct.id);
        }
      } else {
        // Update existing product
        await c.updateProduct(widget.product!.id, payload, newImages);
        
        // Note: For editing, we would need a more complex sync strategy for variants
        // For now, we only create new variants for new products
        // A full implementation would need variant update/delete endpoints
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ المنتج: ${e.toString()}',
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  Future<void> _createVariantTypesForProduct(int productId) async {
    for (var typeData in variantTypesData) {
      // Create variant type
      final typePayload = {
        'name_ar': typeData['nameAr'].text,
        'name_en': typeData['nameEn'].text,
        'sort_order': 0,
      };

      final createdType = await c.createVariantType(productId, typePayload);

      // Create options for this variant type
      if (createdType.id != null) {
        for (var optionData in typeData['options']) {
          final optionPayload = {
            'value_ar': optionData['valueAr'].text,
            'value_en': optionData['valueEn'].text,
            'extra_price': double.tryParse(optionData['extraPrice'].text) ?? 0.0,
            'is_active': true,
            'sort_order': 0,
          };

          await c.createVariantOption(createdType.id!, optionPayload);
        }
      }
    }
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
      backgroundColor: Colors.transparent,
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
                Obx(() => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: categoryId,
                        validator: (v) => v == null ? 'الرجاء اختيار تصنيف' : null,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('اختر تصنيف'),
                          ),
                          ...c.categories
                              .where((cat) => cat.isActive)
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
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _showAddCategoryDialog,
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )),
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
                const SizedBox(height: 8),
                TextFormField(
                  controller: quantity,
                  decoration: const InputDecoration(
                    labelText: 'الكمية المخزنة (اختياري)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'سيتم تعطيل المنتج تلقائيًا إذا كانت الكمية 0',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Variant Types Section
                _buildVariantTypesSection(),
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
