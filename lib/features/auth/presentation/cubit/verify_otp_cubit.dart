// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../data/repos/auth_repo.dart';
// import 'verify_otp_states.dart';
// import '../../../../core/errors/app_exceptions.dart';
//
// class VerifyOtpCubit extends Cubit<VerifyOtpState> {
//   VerifyOtpCubit() : super(VerifyOtpInitial());
//
//   final AuthRepo _repo = AuthRepo.instance;
//
//   // ---------- Verify Register OTP ----------
//   Future<void> verifyRegisterOtp({required String otp}) async {
//     emit(VerifyOtpLoading());
//     try {
//       await _repo.verifyPhoneOtp(otp: otp);
//       emit(VerifyOtpSuccess('تم التحقق من الرمز بنجاح ✅'));
//     } on AppException catch (e) {
//       emit(VerifyOtpError(e.message));
//     } catch (e) {
//       emit(VerifyOtpError('حدث خطأ غير متوقع أثناء التحقق من الرمز.'));
//     }
//   }
//
//   // ---------- Verify Reset Password OTP ----------
//   Future<String?> verifyResetPasswordOtp({
//     required int phone,
//     required String otp,
//   }) async {
//     emit(VerifyOtpLoading());
//     try {
//       final token = await _repo.verifyResetPasswordOTP(
//         phone: phone,
//         otp: otp,
//       );
//
//       emit(VerifyOtpSuccess('تم التحقق من رمز استعادة كلمة المرور بنجاح ✅'));
//       return token;
//     } on AppException catch (e) {
//       emit(VerifyOtpError(e.message));
//       return null;
//     } catch (e) {
//       emit(VerifyOtpError('حدث خطأ غير متوقع أثناء التحقق من رمز استعادة كلمة المرور.'));
//       return null;
//     }
//   }
// }
