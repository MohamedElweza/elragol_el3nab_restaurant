import 'package:dio/dio.dart';
import '../utils/constants/app_constants.dart';

class ApiDiagnostics {
  static Future<void> runDiagnostics() async {
    print('🔍 Running API Diagnostics...');
    print('=' * 50);
    
    await _checkNgrokStatus();
    await _checkApiEndpoint();
    await _testLoginEndpoint();
    
    print('=' * 50);
    print('🔍 Diagnostics Complete');
  }

  static Future<void> _checkNgrokStatus() async {
    print('📡 Testing Ngrok URL...');
    try {
      final dio = Dio();
      final response = await dio.get(
        AppConstants.baseUrl,
        options: Options(
          validateStatus: (status) => true, // Accept any status
          headers: {
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      
      print('✅ Ngrok URL Response: ${response.statusCode}');
      if (response.statusCode == 404) {
        print('❌ 404 - Ngrok tunnel exists but backend not found');
        print('   Solution: Start your backend server');
      } else if (response.statusCode == 200) {
        print('✅ Backend server is running');
      }
      
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        print('❌ Cannot connect to Ngrok URL');
        print('   Solution: Generate new Ngrok URL');
        print('   1. Run: ngrok http [your_backend_port]');
        print('   2. Copy the new https URL');
        print('   3. Update AppConstants.baseUrl');
      } else {
        print('❌ Error: $e');
      }
    }
  }

  static Future<void> _checkApiEndpoint() async {
    print('\n🎯 Testing API Endpoint...');
    try {
      final dio = Dio();
      final response = await dio.get(
        '${AppConstants.baseUrl}/api/v1/vendor',
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'X-api-key': AppConstants.apiKey,
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );
      
      print('API Base Response: ${response.statusCode}');
      if (response.statusCode == 404) {
        print('❌ API base path not found');
        print('   Check if your backend has /api/v1 routes');
      }
      
    } catch (e) {
      print('❌ API Endpoint Error: $e');
    }
  }

  static Future<void> _testLoginEndpoint() async {
    print('\n🔐 Testing Login Endpoint...');
    try {
      final dio = Dio();
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/v1/vendor/auth/login',
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'X-api-key': AppConstants.apiKey,
            'ngrok-skip-browser-warning': 'true',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'phone': 1234567890,
          'password': 'test'
        },
      );
      
      print('Login Endpoint Response: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      if (response.statusCode == 404) {
        print('❌ Login endpoint not found');
        print('   Check if /api/v1/vendor/auth/login route exists');
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        print('✅ Login endpoint exists (returned auth error as expected)');
      }
      
    } catch (e) {
      print('❌ Login Endpoint Error: $e');
    }
  }
}