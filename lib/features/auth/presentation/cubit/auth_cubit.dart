// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:elragol_el3nab/features/auth/data/repos/auth_repo.dart';
// import 'package:elragol_el3nab/features/auth/presentation/cubit/auth_states.dart';
// import '../../../../core/errors/app_exceptions.dart';
// import '../../../../core/storage/app_secure_storage.dart';
//
// class AuthCubit extends Cubit<AuthState> {
//   AuthCubit() : super(AuthInitial());
//
//   final AuthRepo _repo = AuthRepo.instance;
//
//   // ---------- Sign In ----------
//   Future<void> signIn({required int phone, required String password}) async {
//     emit(AuthLoading());
//     try {
//       final user = await _repo.signIn(phone: phone, password: password);
//
//       emit(AuthSignInSuccess(user));
//     } on AppException catch (e) {
//       emit(AuthError(e.message));
//     } catch (e) {
//       emit(AuthError('حدث خطأ غير متوقع أثناء تسجيل الدخول.'));
//     }
//   }
//
//   // ---------- Sign Up ----------
//   Future<void> signUp({
//     required String name,
//     required String email,
//     required int phone,
//     required String password,
//   }) async {
//     emit(AuthLoading());
//     try {
//       final user = await _repo.signUp(
//         name: name,
//         email: email,
//         phone: phone,
//         password: password,
//       );
//       emit(AuthSignUpSuccess(user));
//     } on AppException catch (e) {
//       emit(AuthError(e.message));
//     } catch (e) {
//       emit(AuthError('حدث خطأ غير متوقع أثناء إنشاء الحساب.'));
//     }
//   }
//
//   // ---------- Send OTP ----------
//   Future<void> sendOtp({required int phone}) async {
//     emit(AuthLoading());
//     try {
//       await _repo.sendPhoneOtp();
//       emit(SendOtpSuccess());
//     } on AppException catch (e) {
//       emit(AuthError(e.message));
//     } catch (e) {
//       emit(AuthError('حدث خطأ غير متوقع أثناء إرسال رمز التحقق.'));
//     }
//   }
//
//   // ---------- Send Reset Password OTP ----------
//   Future<void> sendResetPasswordOtp({required int phone}) async {
//     emit(AuthLoading());
//     try {
//       await _repo.sendResetPasswordOTP(phone: phone);
//       emit(SendOtpSuccess());
//     } on AppException catch (e) {
//       emit(AuthError(e.message));
//     } catch (e) {
//       emit(AuthError('حدث خطأ أثناء إرسال رمز استعادة كلمة المرور.'));
//     }
//   }
//
//
//   // ----------  Reset Password  ----------
//   Future<void> resetPassword({
//     required String resetPasswordToken,
//     required String newPassword,
//   }) async {
//     emit(AuthLoading());
//     try {
//       final message = await _repo.resetPassword(
//         resetPasswordToken: resetPasswordToken,
//         newPassword: newPassword,
//       );
//       emit(ResetPasswordSuccess(message));
//     } on AppException catch (e) {
//       emit(AuthError(e.message));
//     } catch (e) {
//       emit(AuthError('حدث خطأ أثناء إعادة تعيين كلمة المرور.'));
//     }
//   }
//
//   // ---------- Logout ----------
//   Future<void> logout() async {
//     try {
//       await _repo.logout();
//       await AppPreferences.clearAccessToken();
//       emit(AuthLoggedOut());
//     } on AppException catch (e) {
//       emit(AuthError(e.message));
//     } catch (e) {
//       emit(AuthError('حدث خطأ أثناء تسجيل الخروج.'));
//     }
//   }
// }
