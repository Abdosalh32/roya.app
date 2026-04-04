import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roya/data/models/category_model.dart';
import 'package:roya/data/models/product_model.dart';
import 'package:roya/data/repositories/products_repository.dart';

class ProductsController extends GetxController {
  final ProductsRepository repository;

  ProductsController(this.repository);

  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxList<ShopCategory> categories = <ShopCategory>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString activeFilter = 'all'.obs; // 'all' | 'active' | 'inactive'
  final RxInt selectedCategoryFilter = (-1).obs; // -1 = all

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final list = await repository.fetchProducts();
      products.assignAll(list);
      applyFilters();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final list = await repository.fetchCategories();
      categories.assignAll(list);
    } catch (e) {
      // ignore
    }
  }

  Future<void> createProduct(
    Map<String, dynamic> data,
    List<XFile> images,
  ) async {
    try {
      isLoading.value = true;
      final files = images.map((x) => File(x.path)).toList();
      final created = await repository.createProduct(data, files);
      products.add(created);
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(
    int id,
    Map<String, dynamic> data,
    List<XFile> newImages,
  ) async {
    try {
      isLoading.value = true;
      final files = newImages.map((x) => File(x.path)).toList();
      final updated = await repository.updateProduct(id, data, files);
      final idx = products.indexWhere((p) => p.id == id);
      if (idx >= 0) products[idx] = updated;
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await repository.deleteProduct(id);
      products.removeWhere((p) => p.id == id);
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  Future<void> toggleProductActive(int id, bool isActive) async {
    try {
      await repository.toggleProductActive(id, isActive);
      final idx = products.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        final p = products[idx];
        products[idx] = p.copyWith(isActive: isActive);
      }
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  void applyFilters() {
    final list = products.where((p) {
      if (activeFilter.value == 'active' && !p.isActive) return false;
      if (activeFilter.value == 'inactive' && p.isActive) return false;
      if (selectedCategoryFilter.value != -1 &&
          p.categoryId != selectedCategoryFilter.value)
        return false;
      return true;
    }).toList();
    filteredProducts.assignAll(list);
  }

  Future<void> refresh() async {
    await fetchCategories();
    await fetchProducts();
  }

  // Category methods
  Future<void> createCategory(String nameAr, String nameEn) async {
    try {
      final cat = await repository.createCategory(nameAr, nameEn);
      categories.add(cat);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  Future<void> updateCategory(
    int id,
    String nameAr,
    String nameEn,
    bool isActive,
  ) async {
    try {
      final cat = await repository.updateCategory(id, nameAr, nameEn, isActive);
      final idx = categories.indexWhere((c) => c.id == id);
      if (idx >= 0) categories[idx] = cat;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await repository.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: const Color(0xFFD32F2F),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }
}
