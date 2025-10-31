import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/auth_repo.dart';
import 'auth_states.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/storage/app_secure_storage.dart';
import '../../../../core/utils/network_helper.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final AuthRepo _repo = AuthRepo.instance;

  // ---------- Sign In ----------
  Future<void> signIn({required int phone, required String password}) async {
    emit(AuthLoading());
    
    // Check network connectivity first
    final isNetworkAvailable = await NetworkHelper.isNetworkAvailable();
    if (!isNetworkAvailable) {
      emit(AuthError('لا يوجد اتصال بالإنترنت، يرجى التحقق من اتصالك والمحاولة مرة أخرى'));
      return;
    }

    // Check if API server is reachable
    final isApiReachable = await NetworkHelper.isApiServerReachable();
    if (!isApiReachable) {
      emit(AuthError('❌ لا يمكن الوصول إلى الخادم\n\nالسبب المحتمل:\n• انتهت صلاحية رابط Ngrok\n• الخادم الخلفي متوقف\n• عدم تشغيل Ngrok\n\nيرجى التحقق من الخادم والمحاولة مرة أخرى'));
      return;
    }

    try {
      print('AuthCubit: Starting sign in for phone: $phone');
      final user = await _repo.signIn(phone: phone, password: password);
      print('AuthCubit: Sign in successful for user: ${user.name}');
      emit(AuthSignInSuccess(user));
    } on AppException catch (e) {
      print('AuthCubit: AppException during sign in: ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      print('AuthCubit: Unexpected error during sign in: $e');
      String errorMessage = 'حدث خطأ غير متوقع أثناء تسجيل الدخول';
      
      // Provide more specific error messages based on error type
      if (e.toString().contains('SocketException')) {
        errorMessage = 'خطأ في الاتصال بالشبكة، يرجى التحقق من اتصال الإنترنت';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'خطأ في تنسيق البيانات المستلمة من الخادم';
      } else if (e.toString().contains('HandshakeException')) {
        errorMessage = 'خطأ في الاتصال الآمن بالخادم';
      }
      
      emit(AuthError('$errorMessage\nتفاصيل الخطأ: ${e.toString()}'));
    }
  }

  // ---------- Check if user is logged in ----------
  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await AppPreferences.isLoggedIn();
      if (isLoggedIn) {
        // Get user data from storage
        final userDataJson = await AppPreferences.getUserData();
        if (userDataJson != null) {
          // You can emit a state indicating user is already logged in
          // For now, we'll just emit initial state
          emit(AuthInitial());
        } else {
          emit(AuthInitial());
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }

  // ---------- Logout ----------
  Future<void> logout() async {
    try {
      await _repo.logout();
      emit(AuthLoggedOut());
    } on AppException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('حدث خطأ أثناء تسجيل الخروج.'));
    }
  }

  // ---------- Clear Error State ----------
  void clearError() {
    if (state is AuthError) {
      emit(AuthInitial());
    }
  }
}
