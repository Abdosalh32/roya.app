class RegionModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String city;
  final bool isActive;

  RegionModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.city,
    required this.isActive,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] as int? ?? 0,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      city: json['city'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
