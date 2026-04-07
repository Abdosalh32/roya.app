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
  final String? logo;

  const ShopModel({this.id, this.name, this.logo});

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as int?,
      name: json['name_ar'] as String? ?? json['name'] as String?,
      logo: json['logo_url'] as String? ?? json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'logo': logo};

  ShopModel copyWith({int? id, String? name, String? logo}) {
    return ShopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
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
