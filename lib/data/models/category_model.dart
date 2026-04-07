class ShopCategory {
  final int id;
  final int? shopId;
  final String nameAr;
  final String nameEn;
  final int sortOrder;
  final bool isActive;

  ShopCategory({
    required this.id,
    this.shopId,
    required this.nameAr,
    required this.nameEn,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory ShopCategory.fromJson(Map<String, dynamic> json) => ShopCategory(
    id: json['id'] as int,
    shopId: json['shop_id'] as int?,
    nameAr: json['name_ar'] as String? ?? '',
    nameEn: json['name_en'] as String? ?? '',
    sortOrder: json['sort_order'] as int? ?? 0,
    isActive: (json['is_active'] as bool?) ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shop_id': shopId,
    'name_ar': nameAr,
    'name_en': nameEn,
    'sort_order': sortOrder,
    'is_active': isActive,
  };
}
