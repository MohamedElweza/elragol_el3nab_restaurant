class UserModel {
  final String id;
  final String name;
  final String? email;
  final int phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isAdmin;
  final String? updatedAt;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isAdmin,
    this.updatedAt,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'], // API uses _id, fallback to id
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? 0,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isAdmin: json['isAdmin'] ?? false,
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'isAdmin': isAdmin,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
    };
  }
}
