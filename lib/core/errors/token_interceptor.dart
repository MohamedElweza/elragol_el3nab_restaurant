import 'package:dio/dio.dart';
import '../storage/app_secure_storage.dart';
import '../utils/constants/app_constants.dart';
import 'app_exceptions.dart';

class TokenInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('🟢 TokenInterceptor - Response received:');
    print('   Status Code: ${response.statusCode}');
    print('   Status Message: ${response.statusMessage}');
    print('   Request URL: ${response.requestOptions.uri}');
    print('   Response Headers: ${response.headers}');
    print('   Response Data: ${response.data}');
    
    handler.next(response);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add API key header to all requests
    options.headers['X-api-key'] = AppConstants.apiKey;
    
    // Add ngrok header to bypass warning
    options.headers['ngrok-skip-browser-warning'] = 'true';
    
    // Only set Content-Type if not already set (to avoid interfering with FormData)
    if (options.contentType == null && options.data != null && options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }
    
    // Add Authorization Bearer token if available (only for authenticated requests)
    final accessToken = await AppPreferences.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      print('🟡 TokenInterceptor - Added Bearer token to request');
    } else {
      print('� TokenInterceptor - No access token (login request or public endpoint)');
    }
    
    print('🟡 TokenInterceptor - Request:');
    print('   Method: ${options.method}');
    print('   URL: ${options.uri}');
    print('   Headers: ${options.headers}');
    print('   Data Type: ${options.data.runtimeType}');
    print('   Content-Type: ${options.contentType}');
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('🔴 TokenInterceptor - Error occurred:');
    print('   Error Type: ${err.type}');
    print('   Error Message: ${err.message}');
    print('   Request URL: ${err.requestOptions.uri}');
    print('   Request Method: ${err.requestOptions.method}');
    print('   Request Headers: ${err.requestOptions.headers}');
    print('   Request Data: ${err.requestOptions.data}');
    print('   Response Status Code: ${err.response?.statusCode}');
    print('   Response Data: ${err.response?.data}');
    print('   Response Headers: ${err.response?.headers}');
    
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      try {
        final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
        final refreshToken = await AppPreferences.getRefreshToken();
        
        if (refreshToken != null) {
          final response = await dio.post(
            '/api/v1/vendor/auth/refresh-token',
            data: {'refreshToken': refreshToken},
            options: Options(headers: {
              'X-api-key': AppConstants.apiKey,
              'ngrok-skip-browser-warning': 'true',
              'Content-Type': 'application/json',
            }),
          );

          if (response.statusCode == 200 && response.data['status'] == 'success') {
            final data = response.data['data'];
            final newAccessToken = data['accessToken'];
            final newRefreshToken = data['refreshToken'];

            // Save new tokens
            await AppPreferences.saveTokens(newAccessToken, newRefreshToken);

            // Retry the original request with new token
            final originalRequest = err.requestOptions;
            originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
            originalRequest.headers['X-api-key'] = AppConstants.apiKey;
            originalRequest.headers['ngrok-skip-browser-warning'] = 'true';

            final retryResponse = await dio.request(
              originalRequest.path,
              options: Options(
                method: originalRequest.method,
                headers: originalRequest.headers,
              ),
              data: originalRequest.data,
              queryParameters: originalRequest.queryParameters,
            );

            return handler.resolve(retryResponse);
          }
        }

        // If refresh fails, clear tokens and throw unauthorized exception
        await AppPreferences.clearTokens();
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً'),
          ),
        );
      } catch (e) {
        await AppPreferences.clearTokens();
        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: const UnauthorizedException('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً'),
          ),
        );
      }
    }

    handler.next(err);
  }
}