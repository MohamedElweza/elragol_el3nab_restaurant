import 'package:dio/dio.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/storage/app_secure_storage.dart';
import '../../../../core/errors/token_interceptor.dart';
import '../../../../core/utils/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/refresh_token_request.dart';
import '../models/refresh_token_response.dart';
import 'dart:convert';

class AuthRepo {
  AuthRepo._();

  static final AuthRepo instance = AuthRepo._();

  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl))
    ..interceptors.add(TokenInterceptor());

  Future<Response> _postRequest(
    String endpoint, {
    Map<String, dynamic>? data,
    bool withAuth = false,
  }) async {
    try {
      print('🟡 Making POST request:');
      print('   Endpoint: $endpoint');
      print('   Full URL: ${AppConstants.baseUrl}$endpoint');
      print('   With Auth: $withAuth');
      print('   Request Data: $data');

      // Don't set headers here - let TokenInterceptor handle them
      // This prevents duplicate header setting which can cause request issues
      final response = await _dio.post(
        endpoint,
        data: data,
        // Remove explicit headers - TokenInterceptor will add them
      );

      print('🟢 Request successful:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Headers: ${response.headers}');
      print('   Response Data: ${response.data}');

      return response;
    } on DioException catch (e) {
      print('🔴 DioException in _postRequest:');
      print('   Error: $e');
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      print('🔴 Unexpected error in _postRequest:');
      print('   Error: $e');
      print('   Error Type: ${e.runtimeType}');
      rethrow;
    }
  }

  // ------------------ Sign In ------------------
  Future<UserModel> signIn({
    required int phone,
    required String password,
  }) async {
    try {
      final loginRequest = LoginRequest(phone: phone, password: password);
      
      print('🟡 AuthRepo.signIn started:');
      print('   Phone: $phone');
      print('   Login request: ${loginRequest.toJson()}');
      
      final response = await _postRequest(
        '/api/v1/vendor/auth/login',
        data: loginRequest.toJson(),
      );

      print('🟢 Login response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Response Data: ${response.data}');
      print('   Response Type: ${response.data.runtimeType}');

      final loginResponse = LoginResponse.fromJson(response.data);
      
      print('🟡 Parsed LoginResponse:');
      print('   Status: ${loginResponse.status}');
      print('   Message: ${loginResponse.message}');
      
      if (loginResponse.status == 'success') {
        print('🟢 Login successful, saving tokens...');
        
        // Save tokens
        await AppPreferences.saveTokens(
          loginResponse.data.accessToken,
          loginResponse.data.refreshToken,
        );
        
        // Save user data
        await AppPreferences.saveUserData(jsonEncode(loginResponse.data.user.toJson()));
        
        print('🟢 Tokens and user data saved successfully');
        print('   User: ${loginResponse.data.user.name}');
        
        return loginResponse.data.user;
      } else {
        print('🔴 Login failed with status: ${loginResponse.status}');
        throw AppException(loginResponse.message.isNotEmpty ? loginResponse.message : 'فشل في تسجيل الدخول');
      }
    } on AppException catch (e) {
      print('🔴 AppException in signIn: ${e.message}');
      rethrow;
    } catch (e) {
      print('🔴 Unexpected error in signIn:');
      print('   Error: $e');
      print('   Error Type: ${e.runtimeType}');
      print('   Stack Trace: ${StackTrace.current}');
      throw AppException('حدث خطأ غير متوقع أثناء تسجيل الدخول: $e');
    }
  }

  // ------------------ Refresh Token ------------------
  Future<void> refreshToken() async {
    try {
      final refreshToken = await AppPreferences.getRefreshToken();
      if (refreshToken == null) {
        throw AppException('لا يوجد رمز تحديث، يرجى تسجيل الدخول مجدداً');
      }

      final refreshRequest = RefreshTokenRequest(refreshToken: refreshToken);
      
      final response = await _postRequest(
        '/api/v1/vendor/auth/refresh-token',
        data: refreshRequest.toJson(),
      );

      final refreshResponse = RefreshTokenResponse.fromJson(response.data);
      
      if (refreshResponse.status == 'success') {
        await AppPreferences.saveTokens(
          refreshResponse.data.accessToken,
          refreshResponse.data.refreshToken,
        );
      } else {
        throw AppException(refreshResponse.message);
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('حدث خطأ أثناء تحديث الرمز المميز: $e');
    }
  }

  // ------------------ Logout ------------------
  Future<bool> logout() async {
    try {
      await _postRequest('/api/v1/vendor/auth/logout', withAuth: true);
      await AppPreferences.clearAll();
      return true;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      throw AppException('حدث خطأ أثناء تسجيل الخروج: $e');
    }
  }
}
