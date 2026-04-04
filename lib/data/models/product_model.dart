class ProductImage {
  final int? id;
  final int? productId;
  final String imageUrl;
  final int sortOrder;
  final bool isPrimary;

  ProductImage({
    this.id,
    this.productId,
    required this.imageUrl,
    this.sortOrder = 0,
    this.isPrimary = false,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    id: json['id'] as int?,
    productId: json['product_id'] as int?,
    imageUrl: json['image_url'] as String? ?? '',
    sortOrder: json['sort_order'] as int? ?? 0,
    isPrimary: (json['is_primary'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'image_url': imageUrl,
    'sort_order': sortOrder,
    'is_primary': isPrimary,
  };
}

class ProductVariantOption {
  final int? id;
  final int? typeId;
  final String valueAr;
  final String valueEn;
  final double extraPrice;
  final bool isActive;
  final int sortOrder;

  ProductVariantOption({
    this.id,
    this.typeId,
    required this.valueAr,
    required this.valueEn,
    this.extraPrice = 0.0,
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory ProductVariantOption.fromJson(Map<String, dynamic> json) =>
      ProductVariantOption(
        id: json['id'] as int?,
        typeId: json['type_id'] as int?,
        valueAr: json['value_ar'] as String? ?? '',
        valueEn: json['value_en'] as String? ?? '',
        extraPrice: (json['extra_price'] != null)
            ? double.tryParse(json['extra_price'].toString()) ?? 0.0
            : 0.0,
        isActive: (json['is_active'] as bool?) ?? true,
        sortOrder: json['sort_order'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type_id': typeId,
    'value_ar': valueAr,
    'value_en': valueEn,
    'extra_price': extraPrice,
    'is_active': isActive,
    'sort_order': sortOrder,
  };
}

class ProductVariantType {
  final int? id;
  final int? productId;
  final String nameAr;
  final String nameEn;
  final int sortOrder;
  final List<ProductVariantOption> options;

  ProductVariantType({
    this.id,
    this.productId,
    required this.nameAr,
    required this.nameEn,
    this.sortOrder = 0,
    this.options = const [],
  });

  factory ProductVariantType.fromJson(Map<String, dynamic> json) =>
      ProductVariantType(
        id: json['id'] as int?,
        productId: json['product_id'] as int?,
        nameAr: json['name_ar'] as String? ?? '',
        nameEn: json['name_en'] as String? ?? '',
        sortOrder: json['sort_order'] as int? ?? 0,
        options:
            (json['options'] as List<dynamic>?)
                ?.map(
                  (e) =>
                      ProductVariantOption.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'name_ar': nameAr,
    'name_en': nameEn,
    'sort_order': sortOrder,
    'options': options.map((o) => o.toJson()).toList(),
  };
}

class Product {
  final int id;
  final int shopId;
  final int? categoryId;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double price;
  final double? comparePrice;
  final bool isActive;
  final int sortOrder;
  final List<ProductImage> images;
  final List<ProductVariantType> variantTypes;

  Product({
    required this.id,
    required this.shopId,
    this.categoryId,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.price,
    this.comparePrice,
    required this.isActive,
    this.sortOrder = 0,
    this.images = const [],
    this.variantTypes = const [],
  });

  Product copyWith({
    int? id,
    int? shopId,
    int? categoryId,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    double? price,
    double? comparePrice,
    bool? isActive,
    int? sortOrder,
    List<ProductImage>? images,
    List<ProductVariantType>? variantTypes,
  }) {
    return Product(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      categoryId: categoryId ?? this.categoryId,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      price: price ?? this.price,
      comparePrice: comparePrice ?? this.comparePrice,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      images: images ?? this.images,
      variantTypes: variantTypes ?? this.variantTypes,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as int,
    shopId: json['shop_id'] as int,
    categoryId: json['category_id'] as int?,
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String? ?? '',
    descriptionAr: json['description_ar'] as String?,
    descriptionEn: json['description_en'] as String?,
    price: (json['price'] != null)
        ? double.tryParse(json['price'].toString()) ?? 0.0
        : 0.0,
    comparePrice: (json['compare_price'] != null)
        ? double.tryParse(json['compare_price'].toString())
        : null,
    isActive: (json['is_active'] as bool?) ?? true,
    sortOrder: json['sort_order'] as int? ?? 0,
    images:
        (json['images'] as List<dynamic>?)
            ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    variantTypes:
        (json['variant_types'] as List<dynamic>?)
            ?.map((e) => ProductVariantType.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'category_id': categoryId,
    'name_ar': nameAr,
    'name_en': nameEn,
    'description_ar': descriptionAr,
    'description_en': descriptionEn,
    'price': price,
    'compare_price': comparePrice,
    'is_active': isActive,
    'sort_order': sortOrder,
    'images': images.map((i) => i.toJson()).toList(),
    'variant_types': variantTypes.map((t) => t.toJson()).toList(),
  };
}
