// lib/features/auth/data/models/login_model.dart

// نماذج البيانات لعملية تسجيل الدخول
// تشمل: الطلب، الاستجابة، بيانات المستخدم، بيانات المتجر

// ─── نموذج طلب تسجيل الدخول ───────────────────────
class LoginRequestModel {
  final String phone;
  final String password;
  final String? fcmToken;

  const LoginRequestModel({
    required this.phone,
    required this.password,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'password': password,
    if (fcmToken != null && fcmToken!.isNotEmpty) 'fcm_token': fcmToken,
  };
}

// ─── نموذج بيانات المتجر ──────────────────────────
class ShopModel {
  final int? id;
  final String? name;
  final String? nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? logo;
  final String? bannerUrl;
  final String? openTime; // Format: "HH:mm" (e.g., "09:00")
  final String? closeTime; // Format: "HH:mm" (e.g., "18:00")
  final List<String>? workingDays; // ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
  final List<Map<String, dynamic>>? workingHours; // [{day_of_week, open_time, close_time, is_closed}]
  final bool? isOpen; // Current open/closed status

  const ShopModel({
    this.id,
    this.name,
    this.nameAr,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.logo,
    this.bannerUrl,
    this.openTime,
    this.closeTime,
    this.workingDays,
    this.workingHours,
    this.isOpen,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as int?,
      name: json['name_ar'] as String? ?? json['name'] as String?,
      nameAr: json['name_ar'] as String?,
      nameEn: json['name_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      logo: json['logo_url'] as String? ?? json['logo'] as String?,
      bannerUrl: json['banner_url'] as String?,
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      workingDays: (json['working_days'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      workingHours: (json['working_hours'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      isOpen: json['is_open'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_ar': nameAr,
        'name_en': nameEn,
        'description_ar': descriptionAr,
        'description_en': descriptionEn,
        'logo_url': logo,
        'banner_url': bannerUrl,
        'open_time': openTime,
        'close_time': closeTime,
        'working_days': workingDays,
        'working_hours': workingHours,
        'is_open': isOpen,
      };

  ShopModel copyWith({
    int? id,
    String? name,
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? logo,
    String? bannerUrl,
    String? openTime,
    String? closeTime,
    List<String>? workingDays,
    List<Map<String, dynamic>>? workingHours,
    bool? isOpen,
  }) {
    return ShopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      logo: logo ?? this.logo,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      workingDays: workingDays ?? this.workingDays,
      workingHours: workingHours ?? this.workingHours,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

// ─── نموذج بيانات المستخدم ───────────────────────
class LoginUserModel {
  final int? id;
  final String? name;
  final String? phone;
  final ShopModel? shop;

  const LoginUserModel({this.id, this.name, this.phone, this.shop});

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      shop: json['shop'] != null
          ? ShopModel.fromJson(json['shop'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'shop': shop?.toJson(),
  };

  LoginUserModel copyWith({
    int? id,
    String? name,
    String? phone,
    ShopModel? shop,
  }) {
    return LoginUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      shop: shop ?? this.shop,
    );
  }
}

// ─── نموذج استجابة تسجيل الدخول ──────────────────
class LoginResponseModel {
  final bool status;
  final String message;
  final String? token;
  final LoginUserModel? user;

  const LoginResponseModel({
    required this.status,
    required this.message,
    this.token,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // استخراج البيانات من الكائن الداخلي "data" إن وُجد
    final data = json['data'] as Map<String, dynamic>?;
    final tokenFromData =
        data?['token'] as String? ?? data?['access_token'] as String?;
    final tokenFromRoot =
        json['token'] as String? ?? json['access_token'] as String?;
    final userMap =
        (data?['user'] as Map<String, dynamic>?) ??
        (json['user'] as Map<String, dynamic>?);

    return LoginResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      token: tokenFromData ?? tokenFromRoot,
      user: userMap != null ? LoginUserModel.fromJson(userMap) : null,
    );
  }

  LoginResponseModel copyWith({
    bool? status,
    String? message,
    String? token,
    LoginUserModel? user,
  }) {
    return LoginResponseModel(
      status: status ?? this.status,
      message: message ?? this.message,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}
