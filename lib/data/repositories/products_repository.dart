import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:roya/data/models/category_model.dart';
import 'package:roya/data/models/product_model.dart';

class ProductsRepository {
  final Dio dio;

  ProductsRepository(this.dio);

  Future<List<Product>> fetchProducts() async {
    final resp = await dio.get('/api/shop-owner/products');
    final data = resp.data as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>?) ?? [];
    return items
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<List<ShopCategory>> fetchCategories() async {
    final resp = await dio.get('/api/shop-owner/categories');
    final data = resp.data as Map<String, dynamic>;
    final items = (data['data'] as List<dynamic>?) ?? [];
    return items
        .map((e) => ShopCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Product> createProduct(
    Map<String, dynamic> payload,
    List<File> images,
  ) async {
    // Postman contract currently defines JSON body for products.
    // Local files from image picker require an upload API to convert to remote URLs.
    if (images.isNotEmpty) {
      debugPrint(
        '⚠️ createProduct received local images but no upload endpoint is configured; submitting payload without local files.',
      );
    }

    final resp = await dio.post('/api/shop-owner/products', data: payload);
    return Product.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<Product> updateProduct(
    int id,
    Map<String, dynamic> payload,
    List<File> newImages,
  ) async {
    if (newImages.isNotEmpty) {
      debugPrint(
        '⚠️ updateProduct received local images but no upload endpoint is configured; submitting payload without local files.',
      );
    }
    final resp = await dio.put('/api/shop-owner/products/$id', data: payload);
    return Product.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await dio.delete('/api/shop-owner/products/$id');
  }

  Future<void> toggleProductActive(int id, bool isActive) async {
    await dio.put('/api/shop-owner/products/$id/toggle');
  }

  // Categories
  Future<ShopCategory> createCategory(String nameAr, String nameEn, {bool isActive = true}) async {
    final resp = await dio.post(
      '/api/shop-owner/categories',
      data: {
        'name_ar': nameAr,
        'name_en': nameEn,
        'sort_order': 0,
        'is_active': isActive,
      },
    );
    return ShopCategory.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<ShopCategory> updateCategory(
    int id,
    String nameAr,
    String nameEn,
    bool isActive,
  ) async {
    final resp = await dio.put(
      '/api/shop-owner/categories/$id',
      data: {
        'name_ar': nameAr,
        'name_en': nameEn,
        'sort_order': 0,
        'is_active': isActive,
      },
    );
    return ShopCategory.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int id) async {
    await dio.delete('/api/shop-owner/categories/$id');
  }
}
