class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const AppException(this.message, {this.statusCode, this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode, super.code});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.code});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.statusCode, super.code});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.statusCode, super.code});
}

class TokenExpiredException extends AppException {
  const TokenExpiredException(super.message, {super.statusCode, super.code});
}