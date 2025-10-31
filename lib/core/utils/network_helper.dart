import 'package:dio/dio.dart';
import '../utils/constants/app_constants.dart';

class NetworkHelper {
  static Future<bool> isNetworkAvailable() async {
    try {
      print('🟡 NetworkHelper: Checking network connectivity...');
      final dio = Dio();
      final response = await dio.get(
        'https://www.google.com',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      print('🟢 NetworkHelper: Network is available (Status: ${response.statusCode})');
      return response.statusCode == 200;
    } catch (e) {
      print('🔴 NetworkHelper: Network not available - $e');
      return false;
    }
  }

  static Future<bool> isApiServerReachable() async {
    try {
      print('🟡 NetworkHelper: Checking API server reachability...');
      print('   URL: ${AppConstants.baseUrl}');
      print('   API Key: ${AppConstants.apiKey}');
      
      final dio = Dio();
      final response = await dio.get(
        AppConstants.baseUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) => status != null && status < 500, // Accept 4xx errors as "reachable"
          headers: {
            'X-api-key': AppConstants.apiKey,
            'ngrok-skip-browser-warning': 'true',
            'Content-Type': 'application/json',
          },
        ),
      );
      print('🟢 NetworkHelper: API server is reachable (Status: ${response.statusCode})');
      print('   Response: ${response.data}');
      return response.statusCode != null;
    } catch (e) {
      print('🔴 NetworkHelper: API server not reachable');
      print('   Error: $e');
      print('   Error Type: ${e.runtimeType}');
      
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        print('   Status Code: $statusCode');
        
        if (statusCode == 404) {
          print('   ❌ 404 Error: This usually means:');
          print('      1. Ngrok URL expired - Generate a new one');
          print('      2. Backend server is not running');
          print('      3. Ngrok tunnel is not active');
          print('      4. Base URL path is incorrect');
        }
      }
      
      return false;
    }
  }
}