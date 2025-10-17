// import 'package:dio/dio.dart';
// import 'package:elragol_el3nab/core/errors/app_exceptions.dart';
// import 'package:elragol_el3nab/core/errors/error_handler.dart';
// import 'package:elragol_el3nab/core/storage/app_secure_storage.dart';
// import '../../../../core/errors/token_interceptor.dart';
// import '../../../../core/utils/constants/app_constants.dart';
// import '../models/user_model.dart';
//
// class AuthRepo {
//   AuthRepo._();
//
//   static final AuthRepo instance = AuthRepo._();
//
//   final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl))
//     ..interceptors.add(TokenInterceptor());
//
//   Future<Response> _postRequest(
//     String endpoint, {
//     Map<String, dynamic>? data,
//     bool withAuth = false,
//   }) async {
//     try {
//       final headers = <String, String>{};
//       if (withAuth) {
//         final token = await AppPreferences.getAccessToken();
//         if (token == null) throw AppException("تم فقد الاتصال بحسابك، يرجى تسجيل الدخول مجددًا.");
//         headers['Authorization'] = 'Bearer $token';
//       }
//
//       final response = await _dio.post(
//         endpoint,
//         data: data,
//         options: Options(headers: headers),
//       );
//
//       return response;
//     } on DioException catch (e) {
//       throw ErrorHandler.handleDioError(e);
//     }
//   }
//
//   // ------------------ Sign Up ------------------
//   Future<UserModel> signUp({
//     required String name,
//     required String email,
//     required String password,
//     required int phone,
//   }) async {
//     try {
//       final response = await _postRequest(
//         '/api/v1/auth/register',
//         data: {
//           "name": name,
//           "email": email,
//           "password": password,
//           "phone": phone,
//         },
//       );
//
//       final data = response.data['data'];
//
//       await AppPreferences.saveTokens(
//         data['accessToken'],
//         data['refreshToken'],
//       );
//       return UserModel.fromJson(data['user']);
//     } catch (e) {
//       throw AppException('Unexpected error during sign up: $e');
//     }
//   }
//
//   // ------------------ Sign In ------------------
//   Future<UserModel> signIn({
//     required int phone,
//     required String password,
//   }) async {
//     try {
//       final response = await _postRequest(
//         '/api/v1/auth/login',
//         data: {"phone": phone, "password": password},
//       );
//
//       final data = response.data['data'];
//       await AppPreferences.saveTokens(
//         data['accessToken'],
//         data['refreshToken'],
//       );
//
//       return UserModel.fromJson(data['user']);
//     } catch (e) {
//       throw AppException('Unexpected error during sign in: $e');
//     }
//   }
//
//   // ------------------ Send Phone OTP ------------------
//   Future<void> sendPhoneOtp() async {
//     try {
//       final response = await _postRequest(
//         '/api/v1/auth/send-phone-otp',
//         withAuth: true,
//       );
//
//       final status = response.data['status'];
//       final message = response.data['message'];
//
//       if (status != 'success') {
//         throw AppException(message ?? 'Failed to send OTP');
//       }
//     } catch (e) {
//       throw AppException('Unexpected error while sending OTP: $e');
//     }
//   }
//
//   // ------------------ Verify Phone OTP ------------------
//   Future<UserModel> verifyPhoneOtp({required String otp}) async {
//     try {
//       final response = await _postRequest(
//         '/api/v1/auth/verify-phone-otp',
//         data: {"otp": otp},
//         withAuth: true,
//       );
//
//       final status = response.data['status'];
//       final message = response.data['message'];
//       final userData = response.data['data']['user'];
//
//       if (status == 'success') {
//         return UserModel.fromJson(userData);
//       } else {
//         throw AppException(message ?? 'Failed to verify OTP');
//       }
//     } catch (e) {
//       throw AppException('Unexpected error while verifying OTP: $e');
//     }
//   }
//
//   // ------------------ Send Reset Password OTP ------------------
//   Future<void> sendResetPasswordOTP({required int phone}) async {
//     try {
//       final response = await _postRequest(
//         '/api/v1/auth/send-reset-password-otp',
//         data: {'phone': phone},
//       );
//
//       final data = response.data;
//       if (data['status'] != 'success') {
//         throw AppException(
//           data['message'] ?? 'Failed to send reset password OTP',
//         );
//       }
//     } catch (e) {
//       throw AppException(
//         'Unexpected error while sending reset password OTP: $e',
//       );
//     }
//   }
//
//   // ------------------ Verify Reset Password OTP ------------------
//   Future<String?> verifyResetPasswordOTP({
//     required int phone,
//     required String otp,
//   }) async {
//     try {
//       final response = await _postRequest(
//         '/api/v1/auth/verify-reset-password-otp',
//         data: {'phone': phone, 'otp': otp},
//       );
//
//       final data = response.data;
//
//       if (data['status'] == 'success') {
//         return data['data']['resetPasswordToken'];
//       } else {
//         throw AppException(
//           data['message'] ?? 'Failed to verify reset password OTP',
//         );
//       }
//     } catch (e) {
//       throw AppException(
//         'Unexpected error while verifying reset password OTP: $e',
//       );
//     }
//   }
//
//   // ------------------ Reset Password ------------------
//   Future<String> resetPassword({
//     required String resetPasswordToken,
//     required String newPassword,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/api/v1/auth/reset-password',
//         data: {'newPassword': newPassword},
//         options: Options(headers: {
//           'Authorization': 'Bearer $resetPasswordToken',
//         }),
//       );
//
//       final data = response.data;
//
//       if (response.statusCode == 200 && data['status'] == 'success') {
//         return data['message'] ?? 'تم إعادة تعيين كلمة المرور بنجاح ✅';
//       } else {
//         throw AppException(
//           data['message'] ?? 'فشل في إعادة تعيين كلمة المرور.',
//         );
//       }
//     } on DioException catch (e) {
//       throw ErrorHandler.handleDioError(e);
//     } catch (e) {
//       throw AppException('حدث خطأ غير متوقع أثناء إعادة تعيين كلمة المرور: $e');
//     }
//   }
//
//
//   // ------------------ Logout ------------------
//   Future<bool> logout() async {
//     try {
//       await _postRequest('/api/v1/auth/logout', withAuth: true);
//       await AppPreferences.clearAccessToken();
//       await AppPreferences.clearRefreshToken();
//       return true;
//     } on DioException catch (e) {
//       throw ErrorHandler.handleDioError(e);
//     }catch (e) {
//       print(e);
//       throw AppException('$e');
//     }
//   }
//
// }
