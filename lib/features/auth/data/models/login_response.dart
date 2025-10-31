import 'user_model.dart';

class LoginResponse {
  final String status;
  final String message;
  final LoginData data;

  LoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: LoginData.fromJson(json['data'] ?? {}),
    );
  }
}

class LoginData {
  final UserModel user;
  final String refreshToken;
  final String accessToken;

  LoginData({
    required this.user,
    required this.refreshToken,
    required this.accessToken,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: UserModel.fromJson(json['user'] ?? {}),
      refreshToken: json['refreshToken'] ?? '',
      accessToken: json['accessToken'] ?? '',
    );
  }
}