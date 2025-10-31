class RefreshTokenResponse {
  final String status;
  final String message;
  final RefreshTokenData data;

  RefreshTokenResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: RefreshTokenData.fromJson(json['data'] ?? {}),
    );
  }
}

class RefreshTokenData {
  final String refreshToken;
  final String accessToken;

  RefreshTokenData({
    required this.refreshToken,
    required this.accessToken,
  });

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) {
    return RefreshTokenData(
      refreshToken: json['refreshToken'] ?? '',
      accessToken: json['accessToken'] ?? '',
    );
  }
}