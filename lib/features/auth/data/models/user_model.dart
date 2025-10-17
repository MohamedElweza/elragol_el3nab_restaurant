class UserModel {
  final String id;
  final String name;
  final String? email;
  final int phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      isEmailVerified: json['isEmailVerified'],
      isPhoneVerified: json['isPhoneVerified'],
      isAdmin: json['isAdmin'],
    );
  }
}
