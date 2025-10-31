import 'package:dio/dio.dart';
import '../../../core/errors/token_interceptor.dart';
import '../data/repos/menu_repository.dart';
import 'menu_cubit.dart';

/// Global provider for MenuCubit to avoid recreating instances
class GlobalMenuProvider {
  static MenuCubit? _instance;
  
  /// Get or create MenuCubit instance
  static MenuCubit getInstance() {
    if (_instance == null) {
      // Create Dio instance with token interceptor
      final dio = Dio();
      dio.interceptors.add(TokenInterceptor());
      
      // Create repository and cubit
      final repository = MenuRepository(dio: dio);
      _instance = MenuCubit(repository);
    }
    
    return _instance!;
  }
  
  /// Clear instance (useful for logout or when switching users)
  static void clearInstance() {
    _instance?.close();
    _instance = null;
  }
  
  /// Check if instance exists
  static bool hasInstance() {
    return _instance != null;
  }
}