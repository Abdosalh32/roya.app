class UserModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String type; // e.g., 'collector', 'distributor', 'shop_owner'

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.type,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      type: json['type'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'type': type,
    };
  }
}

class LoginResponse {
  final String token;
  final UserModel user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}
