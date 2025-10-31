import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/storage/app_secure_storage.dart';
import '../../../../core/utils/network_helper.dart';
import '../../../../core/utils/constants/app_constants.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/menu_category.dart';
import '../models/menu_item.dart';
import '../models/vendor_profile.dart';
import '../models/vendor_category.dart';

class MenuRepository {
  final Dio _dio;
  static const String _baseUrl = '${AppConstants.baseUrl}/api/v1/vendor'; 

  MenuRepository({
    required Dio dio,
  }) : _dio = dio {
    // Configure default headers for the dio instance
    _dio.options.headers = {
      'X-api-key': AppConstants.apiKey,
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
  }

  /// Get the current vendor ID from stored user data
  Future<String> _getVendorId() async {
    try {
      log('📱 MenuRepository: Getting vendor ID from stored user data...');
      
      // First check if we have access token
      final accessToken = await AppPreferences.getAccessToken();
      log('📱 MenuRepository: Access token available: ${accessToken != null && accessToken.isNotEmpty}');
      
      if (accessToken == null || accessToken.isEmpty) {
        log('❌ MenuRepository: No access token found - user not logged in');
        throw AppException('يجب تسجيل الدخول أولاً للوصول إلى هذه الخدمة.');
      }
      
      final userData = await AppPreferences.getUserData();
      log('📱 MenuRepository: User data retrieved: ${userData != null ? 'Found' : 'Not found'}');
      
      if (userData == null) {
        log('❌ MenuRepository: No user data found in storage');
        throw AppException('لم يتم العثور على بيانات المستخدم. يرجى تسجيل الدخول مرة أخرى.');
      }
      
      final userJson = jsonDecode(userData);
      log('📱 MenuRepository: User JSON parsed successfully');
      
      final user = UserModel.fromJson(userJson);
      log('📱 MenuRepository: User model created - ID: ${user.id}');
      
      if (user.id.isEmpty) {
        log('❌ MenuRepository: User ID is empty');
        throw AppException('معرف المستخدم فارغ. يرجى تسجيل الدخول مرة أخرى.');
      }
      
      log('📱 MenuRepository: Vendor ID retrieved successfully: ${user.id}');
      return user.id;
    } catch (e) {
      log('❌ MenuRepository: Error getting vendor ID: $e');
      if (e is AppException) {
        rethrow;
      }
      throw AppException('خطأ في استرجاع بيانات المستخدم. يرجى تسجيل الدخول مرة أخرى.');
    }
  }

  /// Get all vendor categories (types of vendors like "Restaurants", "Fast Food")
  Future<List<VendorCategory>> getVendorCategories() async {
    try {
      log('📱 MenuRepository: Getting vendor categories...');

      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      final url = '$_baseUrl/vendorCategories';
      
      log('📱 MenuRepository: Making GET request to: $url');

      final response = await _dio.get(url);
      
      log('📱 MenuRepository: Get vendor categories response status: ${response.statusCode}');
      log('📱 MenuRepository: Get vendor categories response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final categoriesData = data['data']['vendorCategories'] as List;
          final categories = categoriesData
              .map((categoryJson) => VendorCategory.fromJson(categoryJson))
              .toList();
          
          log('📱 MenuRepository: Successfully loaded ${categories.length} vendor categories');
          return categories;
        } else {
          throw AppException(data['message'] ?? 'فشل في جلب أنواع المطاعم');
        }
      } else {
        throw AppException('خطأ في الخادم: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException getting vendor categories: ${e.message}');
      log('❌ MenuRepository: Response data: ${e.response?.data}');
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ MenuRepository: Unexpected error getting vendor categories: $e');
      throw AppException('حدث خطأ غير متوقع في جلب أنواع المطاعم');
    }
  }

  /// Get all vendors from the API
  Future<List<VendorProfile>> getAllVendors() async {
    try {
      log('📱 MenuRepository: Getting all vendors...');

      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      final url = '$_baseUrl/vendors';
      
      log('📱 MenuRepository: Making GET request to: $url');

      final response = await _dio.get(url);
      
      log('📱 MenuRepository: Get vendors response status: ${response.statusCode}');
      log('📱 MenuRepository: Get vendors response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final vendorsData = data['data']['vendors'] as List;
          final vendors = vendorsData
              .map((vendorJson) => VendorProfile.fromJson(vendorJson))
              .toList();
          
          log('📱 MenuRepository: Successfully loaded ${vendors.length} vendors');
          return vendors;
        } else {
          throw AppException(data['message'] ?? 'فشل في جلب قائمة المطاعم');
        }
      } else {
        throw AppException('خطأ في الخادم: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException getting vendors: ${e.message}');
      log('❌ MenuRepository: Response data: ${e.response?.data}');
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ MenuRepository: Unexpected error getting vendors: $e');
      throw AppException('حدث خطأ غير متوقع في جلب قائمة المطاعم');
    }
  }

  /// Check if vendor profile exists for current user
  Future<bool> checkVendorExists() async {
    try {
      log('📱 MenuRepository: Checking if vendor profile exists...');

      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      // Try to get the vendor profile directly - if it exists, it will return the profile
      // If it doesn't exist, it will throw a 404 exception which we'll catch
      try {
        await getVendorProfile();
        log('📱 MenuRepository: Vendor profile exists for user');
        return true;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          log('📱 MenuRepository: Vendor profile confirmed not found (404)');
          return false;
        }
        // Re-throw other Dio exceptions
        rethrow;
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: Error checking vendor: ${e.message}');
      if (e.response?.statusCode == 404) {
        log('📱 MenuRepository: Vendor profile confirmed not found (404)');
        return false;
      }
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ MenuRepository: Unexpected error checking vendor: $e');
      throw AppException('خطأ في التحقق من بيانات المطعم');
    }
  }

  /// Create vendor profile for current user
  Future<VendorProfile> createVendorProfile(CreateVendorProfileRequest request, {File? image}) async {
    try {
      log('📱 MenuRepository: Creating vendor profile: ${request.name}');

      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      final url = '$_baseUrl/vendors';
      
      log('📱 MenuRepository: Making POST request to: $url');
      log('📱 MenuRepository: Request body: ${request.toJson()}');

      // First create the vendor without image
      final requestData = request.toJson();
      log('📱 MenuRepository: Creating vendor first, then uploading logo if provided');

      final response = await _dio.post(
        url,
        data: requestData,
      );
      
      log('📱 MenuRepository: Create vendor response status: ${response.statusCode}');
      log('📱 MenuRepository: Create vendor response data: ${response.data}');

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final vendorData = data['data']['vendor'];
          var vendor = VendorProfile.fromJson(vendorData);
          
          log('📱 MenuRepository: Successfully created vendor profile: ${vendor.name}');
          
          // If image is provided, upload it separately
          if (image != null) {
            try {
              log('📱 MenuRepository: Uploading logo for vendor: ${vendor.id}');
              vendor = await uploadVendorLogo(vendor.id, image);
              log('📱 MenuRepository: Successfully uploaded logo for vendor: ${vendor.name}');
            } catch (e) {
              log('❌ MenuRepository: Failed to upload logo, but vendor was created: $e');
              // Don't throw error here, vendor was created successfully
              // Logo upload failure shouldn't fail the entire operation
            }
          }
          
          return vendor;
        } else {
          throw AppException(data['message'] ?? 'فشل في إنشاء ملف المطعم');
        }
      } else {
        throw AppException('خطأ في الخادم: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException creating vendor: ${e.message}');
      log('❌ MenuRepository: Response status code: ${e.response?.statusCode}');
      log('❌ MenuRepository: Response data: ${e.response?.data}');
      log('❌ MenuRepository: Response headers: ${e.response?.headers}');
      log('❌ MenuRepository: Request data: ${e.requestOptions.data}');
      log('❌ MenuRepository: Request headers: ${e.requestOptions.headers}');
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ MenuRepository: Unexpected error creating vendor: $e');
      throw AppException('حدث خطأ غير متوقع في إنشاء ملف المطعم');
    }
  }

  /// Upload logo for a vendor
  Future<VendorProfile> uploadVendorLogo(String vendorId, File image) async {
    try {
      log('📱 MenuRepository: Uploading logo for vendor: $vendorId');

      // Use the correct vendor logo upload endpoint
      final logoUrl = '$_baseUrl/vendors/$vendorId/logo';
      
      // Check file exists and get size
      if (!await image.exists()) {
        throw AppException('ملف الصورة غير موجود');
      }
      
      final fileSize = await image.length();
      log('📱 MenuRepository: Image file size: ${fileSize} bytes');
      
      if (fileSize > 10 * 1024 * 1024) { // 10MB limit
        throw AppException('حجم الصورة كبير جداً (الحد الأقصى 10MB)');
      }
      
      // Create a clean Dio instance for file upload to avoid interceptor conflicts
      final uploadDio = Dio();
      
      // Get auth token from secure storage
      final token = await AppPreferences.getAccessToken();
      
      // Create FormData with the logo image
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: 'vendor_${vendorId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      log('📱 MenuRepository: Making POST request to: $logoUrl');
      log('📱 MenuRepository: FormData field name: logo');
      log('📱 MenuRepository: Image file path: ${image.path}');

      final response = await uploadDio.post(
        logoUrl,
        data: formData,
        options: Options(
          // Increase timeout for file uploads
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
          headers: {
            'X-api-key': AppConstants.apiKey,
            'ngrok-skip-browser-warning': 'true',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );
      
      log('📱 MenuRepository: Logo upload response status: ${response.statusCode}');
      log('📱 MenuRepository: Logo upload response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data is Map<String, dynamic>) {
          if (data['status'] == 'success' && data['data'] != null) {
            final vendorData = data['data']['vendor'];
            if (vendorData != null) {
              final updatedVendor = VendorProfile.fromJson(vendorData);
              log('📱 MenuRepository: Successfully uploaded logo for vendor: ${updatedVendor.name}');
              return updatedVendor;
            } else {
              log('❌ MenuRepository: Vendor data is null in logo upload response');
              throw AppException('Server returned invalid vendor data after logo upload');
            }
          } else {
            final errorMessage = data['message'] ?? 'Failed to upload logo';
            log('❌ MenuRepository: Server returned error for logo upload: $errorMessage');
            throw AppException(errorMessage);
          }
        } else {
          log('❌ MenuRepository: Invalid response format for logo upload');
          throw AppException('Server returned invalid response format for logo upload');
        }
      } else {
        log('❌ MenuRepository: Unexpected status code for logo upload: ${response.statusCode}');
        throw AppException('Server error during logo upload: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException uploading logo: ${e.message}');
      log('❌ MenuRepository: Logo upload response status code: ${e.response?.statusCode}');
      log('❌ MenuRepository: Logo upload response data: ${e.response?.data}');
      throw AppException('فشل في رفع الشعار: ${_handleDioError(e)}');
    } catch (e) {
      log('❌ MenuRepository: Unexpected error uploading logo: $e');
      throw AppException('حدث خطأ غير متوقع في رفع الشعار');
    }
  }

  /// Get vendor profile for current user
  Future<VendorProfile> getVendorProfile() async {
    try {
      log('📱 MenuRepository: Getting vendor profile...');

      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      final userId = await _getVendorId();
      
      // Get all vendors and find current user's vendor
      final vendors = await getAllVendors();
      final userVendor = vendors.where((vendor) => vendor.owner == userId).firstOrNull;
      
      if (userVendor != null) {
        log('📱 MenuRepository: Successfully retrieved vendor profile: ${userVendor.name} (ID: ${userVendor.id})');
        return userVendor;
      } else {
        log('❌ MenuRepository: No vendor found for user: $userId');
        // Throw a specific DioException with 404 to be consistent with API responses
        throw DioException(
          requestOptions: RequestOptions(path: '/vendors'),
          response: Response(
            requestOptions: RequestOptions(path: '/vendors'),
            statusCode: 404,
            data: {'status': 'error', 'message': 'Vendor not found'},
          ),
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException getting vendor: ${e.message}');
      log('❌ MenuRepository: Response data: ${e.response?.data}');
      rethrow; // Re-throw DioException as-is for proper handling upstream
    } catch (e) {
      log('❌ MenuRepository: Unexpected error getting vendor: $e');
      throw AppException('حدث خطأ غير متوقع في جلب بيانات المطعم');
    }
  }

  /// Get all menu categories for the vendor
  Future<List<MenuCategory>> getMenuCategories() async {
    try {
      log('📱 MenuRepository: Loading menu categories...');

      // Check network connectivity first
      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      // Get the vendor profile first to get the actual vendor ID
      final vendorProfile = await getVendorProfile();
      final vendorId = vendorProfile.id;
      final url = '$_baseUrl/vendors/$vendorId/categories';
      
      log('📱 MenuRepository: Making GET request to: $url');

      final response = await _dio.get(url);
      
      log('📱 MenuRepository: Response status: ${response.statusCode}');
      log('📱 MenuRepository: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final categoriesData = data['data']['menuCategories'] as List;
          final categories = categoriesData
              .map((categoryJson) => MenuCategory.fromJson(categoryJson))
              .toList();
          
          log('📱 MenuRepository: Successfully loaded ${categories.length} categories');
          return categories;
        } else {
          throw AppException(data['message'] ?? 'Failed to load categories');
        }
      } else {
        throw AppException('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException occurred: ${e.message}');
      log('❌ MenuRepository: Response data: ${e.response?.data}');
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ MenuRepository: Unexpected error: $e');
      throw AppException('حدث خطأ غير متوقع');
    }
  }

  /// Create a new menu category
  Future<MenuCategory> createMenuCategory(CreateMenuCategoryRequest request) async {
    try {
      log('📱 MenuRepository: Creating menu category: ${request.name}');

      // Check network connectivity first
      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      // Get the vendor profile first to get the actual vendor ID
      final vendorProfile = await getVendorProfile();
      final vendorId = vendorProfile.id;
      final url = '$_baseUrl/vendors/$vendorId/categories';
      
      log('📱 MenuRepository: Making POST request to: $url');
      log('📱 MenuRepository: Request body: ${request.toJson()}');

      final response = await _dio.post(
        url,
        data: request.toJson(),
      );
      
      log('📱 MenuRepository: Response status: ${response.statusCode}');
      log('📱 MenuRepository: Response data: ${response.data}');

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final categoryData = data['data']['menuCategory'];
          final category = MenuCategory.fromJson(categoryData);
          
          log('📱 MenuRepository: Successfully created category: ${category.name}');
          return category;
        } else {
          throw AppException(data['message'] ?? 'Failed to create category');
        }
      } else {
        throw AppException('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException occurred: ${e.message}');
      log('❌ MenuRepository: Response data: ${e.response?.data}');
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ MenuRepository: Unexpected error: $e');
      throw AppException('حدث خطأ غير متوقع');
    }
  }

  /// Delete a menu category
  Future<void> deleteMenuCategory(String categoryId) async {
    try {
      log('📱 MenuRepository: Deleting menu category: $categoryId');

      // Check network connectivity first
      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      // Get the vendor profile first to get the actual vendor ID
      final vendorProfile = await getVendorProfile();
      final vendorId = vendorProfile.id;
      final url = '$_baseUrl/vendors/$vendorId/categories/$categoryId';
      
      log('📱 MenuRepository: Making DELETE request to: $url');

      final response = await _dio.delete(url);
      
      log('📱 MenuRepository: Response status: ${response.statusCode}');
      log('📱 MenuRepository: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          log('📱 MenuRepository: Successfully deleted category');
        } else {
          throw AppException(data['message'] ?? 'Failed to delete category');
        }
      } else {
        throw AppException('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException occurred: ${e.message}');
      log('❌ MenuRepository: Response data: ${e.response?.data}');
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ MenuRepository: Unexpected error: $e');
      throw AppException('حدث خطأ غير متوقع');
    }
  }

  /// Get all items in a specific category
  Future<List<MenuItem>> getItemsInCategory(String categoryId) async {
    try {
      log('📱 MenuRepository: Loading items for category: $categoryId');

      // Check network connectivity first
      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      // Get the vendor profile first to get the actual vendor ID
      final vendorProfile = await getVendorProfile();
      final vendorId = vendorProfile.id;
      final url = '$_baseUrl/vendors/$vendorId/categories/$categoryId/items';
      
      log('📱 MenuRepository: Making GET request to: $url');

      final response = await _dio.get(url);
      
      log('📱 MenuRepository: Response status: ${response.statusCode}');
      log('📱 MenuRepository: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success' && data['data'] != null) {
          final itemsData = data['data']['items'] as List;
          final items = itemsData
              .map((itemJson) => MenuItem.fromJson(itemJson))
              .toList();
          
          log('📱 MenuRepository: Successfully loaded ${items.length} items');
          return items;
        } else {
          throw AppException(data['message'] ?? 'Failed to load items');
        }
      } else {
        throw AppException('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException occurred: ${e.message}');
      log('❌ MenuRepository: Response data: ${e.response?.data}');
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ MenuRepository: Unexpected error: $e');
      throw AppException('حدث خطأ غير متوقع');
    }
  }

  /// Create a new menu item in a category
  Future<MenuItem> createMenuItem(String categoryId, CreateMenuItemRequest request, {File? image}) async {
    try {
      log('📱 MenuRepository: Creating menu item: ${request.name} in category: $categoryId');

      // Check network connectivity first
      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      // Get the vendor profile first to get the actual vendor ID
      final vendorProfile = await getVendorProfile();
      final vendorId = vendorProfile.id;
      final url = '$_baseUrl/vendors/$vendorId/categories/$categoryId/items';
      
      log('📱 MenuRepository: Making POST request to: $url');
      log('📱 MenuRepository: Request body: ${request.toJson()}');

      // First create the item without image
      final requestData = request.toJson();
      log('📱 MenuRepository: Creating item first, then uploading image if provided');

      final response = await _dio.post(
        url,
        data: requestData,
      );
      
      log('📱 MenuRepository: Response status: ${response.statusCode}');
      log('📱 MenuRepository: Response data: ${response.data}');

      // Accept both 200 and 201 status codes for successful creation
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data is Map<String, dynamic>) {
          if (data['status'] == 'success' && data['data'] != null) {
            final itemData = data['data']['item'];
            if (itemData != null) {
              var item = MenuItem.fromJson(itemData);
              log('📱 MenuRepository: Successfully created item: ${item.name}');
              
              // If image is provided, upload it separately
              if (image != null) {
                try {
                  log('📱 MenuRepository: Uploading image for item: ${item.id}');
                  item = await _uploadItemImage(vendorId, categoryId, item.id, image);
                  log('📱 MenuRepository: Successfully uploaded image for item: ${item.name}');
                } catch (e) {
                  log('❌ MenuRepository: Failed to upload image, but item was created: $e');
                  // Don't throw error here, item was created successfully
                  // Image upload failure shouldn't fail the entire operation
                }
              }
              
              return item;
            } else {
              log('❌ MenuRepository: Item data is null in response');
              throw AppException('Server returned invalid item data');
            }
          } else {
            final errorMessage = data['message'] ?? 'Failed to create item';
            log('❌ MenuRepository: Server returned error: $errorMessage');
            throw AppException(errorMessage);
          }
        } else {
          log('❌ MenuRepository: Invalid response format');
          throw AppException('Server returned invalid response format');
        }
      } else {
        log('❌ MenuRepository: Unexpected status code: ${response.statusCode}');
        throw AppException('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException creating item: ${e.message}');
      log('❌ MenuRepository: Response status code: ${e.response?.statusCode}');
      log('❌ MenuRepository: Response data: ${e.response?.data}');
      log('❌ MenuRepository: Response headers: ${e.response?.headers}');
      log('❌ MenuRepository: Request data: ${e.requestOptions.data}');
      log('❌ MenuRepository: Request headers: ${e.requestOptions.headers}');
      
      // Provide more specific error handling for 500 errors
      if (e.response?.statusCode == 500) {
        final responseData = e.response?.data;
        if (responseData != null && responseData is Map<String, dynamic>) {
          final serverMessage = responseData['message'] ?? 'Server internal error';
          log('❌ MenuRepository: Server error message: $serverMessage');
          throw AppException('خطأ في الخادم: $serverMessage');
        } else {
          throw AppException('خطأ في الخادم. يرجى المحاولة لاحقاً');
        }
      }
      
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ MenuRepository: Unexpected error creating item: $e');
      throw AppException('حدث خطأ غير متوقع في إنشاء الصنف');
    }
  }

  /// Upload image for a menu item
  Future<MenuItem> _uploadItemImage(String vendorId, String categoryId, String itemId, File image) async {
    try {
      log('📱 MenuRepository: Uploading image for item: $itemId');

      final imageUrl = '$_baseUrl/vendors/$vendorId/categories/$categoryId/items/$itemId/image';
      
      // Create FormData with the image
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: 'item_${itemId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      log('📱 MenuRepository: Making POST request to: $imageUrl');

      final response = await _dio.post(
        imageUrl,
        data: formData,
      );
      
      log('📱 MenuRepository: Image upload response status: ${response.statusCode}');
      log('📱 MenuRepository: Image upload response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null && data is Map<String, dynamic>) {
          if (data['status'] == 'success' && data['data'] != null) {
            final itemData = data['data']['item'];
            if (itemData != null) {
              final updatedItem = MenuItem.fromJson(itemData);
              log('📱 MenuRepository: Successfully uploaded image for item: ${updatedItem.name}');
              return updatedItem;
            } else {
              log('❌ MenuRepository: Item data is null in image upload response');
              throw AppException('Server returned invalid item data after image upload');
            }
          } else {
            final errorMessage = data['message'] ?? 'Failed to upload image';
            log('❌ MenuRepository: Server returned error for image upload: $errorMessage');
            throw AppException(errorMessage);
          }
        } else {
          log('❌ MenuRepository: Invalid response format for image upload');
          throw AppException('Server returned invalid response format for image upload');
        }
      } else {
        log('❌ MenuRepository: Unexpected status code for image upload: ${response.statusCode}');
        throw AppException('Server error during image upload: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException uploading image: ${e.message}');
      log('❌ MenuRepository: Image upload response status code: ${e.response?.statusCode}');
      log('❌ MenuRepository: Image upload response data: ${e.response?.data}');
      throw AppException('فشل في رفع الصورة: ${_handleDioError(e)}');
    } catch (e) {
      log('❌ MenuRepository: Unexpected error uploading image: $e');
      throw AppException('حدث خطأ غير متوقع في رفع الصورة');
    }
  }

  /// Delete a menu item
  Future<void> deleteMenuItem(String itemId) async {
    try {
      log('📱 MenuRepository: Deleting menu item: $itemId');

      // Check network connectivity first
      final hasNetwork = await NetworkHelper.isNetworkAvailable();
      if (!hasNetwork) {
        throw AppException('لا يوجد اتصال بالإنترنت');
      }

      // Get the vendor profile first to get the actual vendor ID
      final vendorProfile = await getVendorProfile();
      final vendorId = vendorProfile.id;
      final url = '$_baseUrl/vendors/$vendorId/items/$itemId';
      
      log('📱 MenuRepository: Making DELETE request to: $url');

      final response = await _dio.delete(url);
      
      log('📱 MenuRepository: Response status: ${response.statusCode}');
      log('📱 MenuRepository: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          log('📱 MenuRepository: Successfully deleted item');
        } else {
          throw AppException(data['message'] ?? 'Failed to delete item');
        }
      } else {
        throw AppException('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log('❌ MenuRepository: DioException occurred: ${e.message}');
      log('❌ MenuRepository: Response data: ${e.response?.data}');
      throw AppException(_handleDioError(e));
    } catch (e) {
      log('❌ MenuRepository: Unexpected error: $e');
      throw AppException('حدث خطأ غير متوقع');
    }
  }

  /// Handle Dio errors and return user-friendly messages
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        if (statusCode == 401) {
          return 'انتهت صلاحية جلسة المستخدم. يرجى تسجيل الدخول مرة أخرى';
        } else if (statusCode == 404) {
          return 'الخدمة غير متاحة حالياً';
        } else if (statusCode == 500) {
          return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
        } else if (responseData != null && responseData['message'] != null) {
          return responseData['message'];
        } else {
          return 'خطأ في الخادم: $statusCode';
        }

      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';

      case DioExceptionType.connectionError:
        return 'فشل في الاتصال بالخادم';

      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}