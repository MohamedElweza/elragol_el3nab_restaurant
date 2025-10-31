import 'package:dio/dio.dart';
import 'app_exceptions.dart';

class ErrorHandler {
  static AppException handleDioError(DioException dioError) {
    print('🔴 DioException occurred:');
    print('   Type: ${dioError.type}');
    print('   Message: ${dioError.message}');
    print('   Request URL: ${dioError.requestOptions.uri}');
    print('   Request Headers: ${dioError.requestOptions.headers}');
    print('   Request Data: ${dioError.requestOptions.data}');
    print('   Response Status: ${dioError.response?.statusCode}');
    print('   Response Data: ${dioError.response?.data}');
    print('   Response Headers: ${dioError.response?.headers}');
    
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        print('🔴 Timeout error occurred');
        return const NetworkException(
          'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى',
        );

      case DioExceptionType.badResponse:
        print('🔴 Bad response error occurred');
        return _handleStatusCodeError(dioError);

      case DioExceptionType.connectionError:
        print('🔴 Connection error occurred');
        return const NetworkException(
          'خطأ في الاتصال، يرجى التحقق من اتصال الإنترنت',
        );

      case DioExceptionType.cancel:
        print('🔴 Request was cancelled');
        return const AppException('تم إلغاء الطلب');

      default:
        print('🔴 Unknown DioException type: ${dioError.type}');
        return const AppException('حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  static AppException _handleStatusCodeError(DioException dioError) {
    final response = dioError.response;
    final statusCode = response?.statusCode;
    final responseData = response?.data;

    print('🔴 Handling status code error:');
    print('   Status Code: $statusCode');
    print('   Response Data Type: ${responseData.runtimeType}');
    print('   Response Data: $responseData');

    String message = 'حدث خطأ غير متوقع';

    // Try to extract error message from response
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? 
                responseData['error'] ?? 
                responseData['errors']?.toString() ?? 
                message;
      print('   Extracted message: $message');
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message.isNotEmpty ? message : 'بيانات غير صحيحة',
          statusCode: statusCode,
        );

      case 401:
        return UnauthorizedException(
          message.isNotEmpty ? message : 'غير مصرح لك بالوصول',
          statusCode: statusCode,
        );

      case 403:
        return UnauthorizedException(
          message.isNotEmpty ? message : 'ممنوع من الوصول',
          statusCode: statusCode,
        );

      case 404:
        return AppException(
          message.isNotEmpty ? message : 'المورد المطلوب غير موجود',
          statusCode: statusCode,
        );

      case 422:
        return ValidationException(
          message.isNotEmpty ? message : 'بيانات غير صالحة',
          statusCode: statusCode,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          'خطأ في الخادم، يرجى المحاولة لاحقاً',
          statusCode: statusCode,
        );

      default:
        return AppException(
          message.isNotEmpty ? message : 'حدث خطأ غير متوقع',
          statusCode: statusCode,
        );
    }
  }
}