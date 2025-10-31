import 'package:dio/dio.dart';
import '../utils/constants/app_constants.dart';

class PostRequestTester {
  static Future<void> testPost() async {
    print('🧪 Testing POST Request to Login API...');
    print('=' * 50);
    
    try {
      final dio = Dio();
      
      // Test data
      final testData = {
        'phone': 1220020078,
        'password': 'test123'
      };
      
      print('📡 Making POST request to: ${AppConstants.baseUrl}/api/v1/vendor/auth/login');
      print('📦 Request Data: $testData');
      print('🔑 API Key: ${AppConstants.apiKey}');
      
      final response = await dio.post(
        '${AppConstants.baseUrl}/api/v1/vendor/auth/login',
        options: Options(
          validateStatus: (status) => true, // Accept any status for testing
          headers: {
            'X-api-key': AppConstants.apiKey,
            'ngrok-skip-browser-warning': 'true',
            'Content-Type': 'application/json',
          },
        ),
        data: testData,
      );
      
      print('✅ POST Request Completed!');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📋 Response Data: ${response.data}');
      
      // Analyze the response
      if (response.statusCode == 200) {
        print('🎉 SUCCESS: Login API is working!');
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        print('✅ ENDPOINT WORKS: Got authentication error (expected with test data)');
      } else if (response.statusCode == 404) {
        print('❌ ENDPOINT NOT FOUND: Check if /api/v1/vendor/auth/login exists');
      } else if (response.statusCode == 500) {
        print('❌ SERVER ERROR: Check backend server logs');
      } else {
        print('⚠️ UNEXPECTED STATUS: ${response.statusCode}');
      }
      
    } catch (e) {
      print('🔴 POST Request Failed:');
      print('   Error: $e');
      
      if (e is DioException) {
        print('   Error Type: ${e.type}');
        print('   Response Status: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        
        if (e.type == DioExceptionType.connectionError) {
          print('❌ CONNECTION ISSUE: Check if server is running and ngrok is active');
        }
      }
    }
    
    print('=' * 50);
  }
  
  static Future<void> testWithRealCredentials({
    required int phone,
    required String password,
  }) async {
    print('🔐 Testing POST with Real Credentials...');
    print('=' * 50);
    
    try {
      final dio = Dio();
      
      final loginData = {
        'phone': phone,
        'password': password
      };
      
      print('📡 Making POST request to: ${AppConstants.baseUrl}/api/v1/vendor/auth/login');
      print('📦 Request Data: {phone: $phone, password: [HIDDEN]}');
      
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
        data: loginData,
      );
      
      print('✅ POST Request Completed!');
      print('📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('🎉 LOGIN SUCCESS!');
        final data = response.data;
        if (data is Map && data['status'] == 'success') {
          print('✅ Valid response format');
          print('👤 User: ${data['data']?['user']?['name'] ?? 'Unknown'}');
          print('🔑 Access Token: ${data['data']?['accessToken'] != null ? 'Present' : 'Missing'}');
          print('🔄 Refresh Token: ${data['data']?['refreshToken'] != null ? 'Present' : 'Missing'}');
        }
      } else {
        print('❌ LOGIN FAILED');
        print('📋 Response: ${response.data}');
      }
      
    } catch (e) {
      print('🔴 POST Request with Real Credentials Failed:');
      print('   Error: $e');
    }
    
    print('=' * 50);
  }
}