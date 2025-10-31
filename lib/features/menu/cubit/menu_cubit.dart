import 'dart:developer';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/menu_category.dart';
import '../data/models/menu_item.dart';
import '../data/models/vendor_profile.dart';
import '../data/repos/menu_repository.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  final MenuRepository _menuRepository;

  // Cache for performance optimization
  List<MenuCategory>? _cachedCategories;
  Map<String, List<MenuItem>> _cachedItems = {};
  DateTime? _lastCategoriesUpdate;
  Map<String, DateTime> _lastItemsUpdate = {};
  
  // Vendor profile caching
  dynamic _cachedVendorProfile;
  DateTime? _lastVendorUpdate;
  
  // Cache duration (15 minutes for categories, they don't change frequently)
  static const Duration _cacheDuration = Duration(minutes: 15);

  MenuCubit(this._menuRepository) : super(MenuInitial());

  /// Expose the repository for external access
  MenuRepository get repository => _menuRepository;

  /// Safe emit method to prevent "Cannot emit new states after calling close" error
  void _safeEmit(MenuState state) {
    if (!isClosed) {
      emit(state);
    } else {
      log('⚠️ MenuCubit: Attempted to emit state after close: $state');
    }
  }

  /// Check if cache is valid
  bool _isCacheValid(DateTime? lastUpdate) {
    if (lastUpdate == null) return false;
    return DateTime.now().difference(lastUpdate) < _cacheDuration;
  }

  /// Clear all caches
  void _clearCache() {
    _cachedCategories = null;
    _cachedItems.clear();
    _lastCategoriesUpdate = null;
    _lastItemsUpdate.clear();
    _cachedVendorProfile = null;
    _lastVendorUpdate = null;
  }

  /// Handle common errors and return Arabic error messages
  String _handleError(String error) {
    if (error.contains('401') || error.contains('Missing token') || error.contains('unauthorized')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    } else if (error.contains('يجب تسجيل الدخول أولاً')) {
      return error; // Keep the Arabic message from repository
    } else if (error.contains('Network') || error.contains('connection')) {
      return 'خطأ في الاتصال بالخادم. يرجى التحقق من الاتصال بالإنترنت.';
    } else if (error.contains('500') || error.contains('server')) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً.';
    } else if (error.contains('400') || error.contains('Bad Request')) {
      return 'بيانات غير صحيحة. يرجى التحقق من المدخلات.';
    } else if (error.contains('404') || error.contains('Not Found')) {
      return 'العنصر المطلوب غير موجود.';
    }
    return error; // Return original error if no specific handling
  }

  /// Load vendor profile first (initial entry point)
  Future<void> loadVendorProfile({bool forceRefresh = false}) async {
    try {
      _safeEmit(MenuLoadingVendor());
      log('🍽️ MenuCubit: Loading vendor profile...');
      
      // First check if vendor exists
      final vendorExists = await _menuRepository.checkVendorExists();
      
      if (!vendorExists) {
        log('🍽️ MenuCubit: Vendor not found - prompting for creation');
        _safeEmit(const MenuVendorNotFound());
        return;
      }
      
      // Get vendor profile
      final vendor = await _menuRepository.getVendorProfile();
      
      log('🍽️ MenuCubit: Successfully loaded vendor profile: ${vendor.name}');
      _safeEmit(MenuVendorLoaded(vendor));
      
      // Preload categories in background for better performance
      _preloadCategoriesInBackground();
    } catch (e) {
      log('❌ MenuCubit: Error loading vendor profile: $e');
      String errorMessage = _handleError(e.toString());
      _safeEmit(MenuError(errorMessage));
    }
  }

  /// Load all menu categories for the vendor
  Future<void> loadMenuCategories({bool forceRefresh = false, bool showLoadingState = true}) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh && 
          _cachedCategories != null && 
          _isCacheValid(_lastCategoriesUpdate)) {
        log('🍽️ MenuCubit: Using cached categories (${_cachedCategories!.length} categories)');
        _safeEmit(MenuCategoriesLoaded(_cachedCategories!));
        return;
      }

      // If we have cached data but it's expired, show it immediately while refreshing
      if (!forceRefresh && _cachedCategories != null) {
        log('🍽️ MenuCubit: Showing stale cache while refreshing in background (${_cachedCategories!.length} categories)');
        _safeEmit(MenuCategoriesLoaded(_cachedCategories!));
        
        // Refresh in background without showing loading state
        _refreshCategoriesInBackground();
        return;
      }

      if (showLoadingState) {
        _safeEmit(MenuCategoriesLoading());
      }
      log('🍽️ MenuCubit: Loading menu categories from API...');
      
      final categories = await _menuRepository.getMenuCategories();
      
      // Cache the results
      _cachedCategories = categories;
      _lastCategoriesUpdate = DateTime.now();
      
      log('🍽️ MenuCubit: Successfully loaded ${categories.length} categories');
      _safeEmit(MenuCategoriesLoaded(categories));
    } catch (e) {
      log('❌ MenuCubit: Error loading categories: $e');
      String errorMessage = _handleError(e.toString());
      
      // Check if it's a vendor not found error
      if (errorMessage.contains('الخدمة غير متاحة حالياً') || 
          errorMessage.contains('Vendor not found') ||
          e.toString().contains('404')) {
        log('🍽️ MenuCubit: Detected vendor not found - prompting for creation');
        _safeEmit(const MenuVendorNotFound());
      } else {
        _safeEmit(MenuCategoriesError(errorMessage));
      }
    }
  }

  /// Preload categories in background without showing loading state
  void _preloadCategoriesInBackground() {
    // Only preload if cache is invalid or doesn't exist
    if (_cachedCategories == null || !_isCacheValid(_lastCategoriesUpdate)) {
      log('🍽️ MenuCubit: Preloading categories in background...');
      
      // Preload without changing current state
      _menuRepository.getMenuCategories().then((categories) {
        // Cache the results silently
        _cachedCategories = categories;
        _lastCategoriesUpdate = DateTime.now();
        log('🍽️ MenuCubit: Background preload completed - ${categories.length} categories cached');
      }).catchError((error) {
        log('❌ MenuCubit: Background preload failed: $error');
        // Don't emit error state for background operations
      });
    } else {
      log('🍽️ MenuCubit: Categories already cached, skipping background preload');
    }
  }

  /// Refresh categories in background without affecting UI state
  void _refreshCategoriesInBackground() {
    log('🍽️ MenuCubit: Refreshing categories in background...');
    
    _menuRepository.getMenuCategories().then((categories) {
      // Update cache silently
      _cachedCategories = categories;
      _lastCategoriesUpdate = DateTime.now();
      
      // Only emit new state if categories actually changed
      if (state is MenuCategoriesLoaded) {
        final currentCategories = (state as MenuCategoriesLoaded).categories;
        if (_categoriesChanged(currentCategories, categories)) {
          log('🍽️ MenuCubit: Categories updated in background, refreshing UI');
          _safeEmit(MenuCategoriesLoaded(categories));
        } else {
          log('🍽️ MenuCubit: Categories unchanged, keeping current UI');
        }
      }
    }).catchError((error) {
      log('❌ MenuCubit: Background refresh failed: $error');
      // Don't emit error state for background operations
    });
  }

  /// Check if categories list has changed (simple comparison by length and IDs)
  bool _categoriesChanged(List<MenuCategory> oldList, List<MenuCategory> newList) {
    if (oldList.length != newList.length) return true;
    
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].id != newList[i].id || oldList[i].name != newList[i].name) {
        return true;
      }
    }
    return false;
  }

  /// Refresh menu items in background without affecting UI state
  void _refreshItemsInBackground(String categoryId, String categoryName) {
    log('🍽️ MenuCubit: Refreshing items for category $categoryId in background...');
    
    _menuRepository.getItemsInCategory(categoryId).then((items) {
      // Update cache silently
      _cachedItems[categoryId] = items;
      _lastItemsUpdate[categoryId] = DateTime.now();
      
      // Only emit new state if items actually changed and we're still viewing this category
      if (state is MenuItemsLoaded) {
        final currentState = state as MenuItemsLoaded;
        if (currentState.categoryId == categoryId && _itemsChanged(currentState.items, items)) {
          log('🍽️ MenuCubit: Items updated in background for category $categoryId, refreshing UI');
          _safeEmit(MenuItemsLoaded(items, categoryId, categoryName));
        } else {
          log('🍽️ MenuCubit: Items unchanged for category $categoryId, keeping current UI');
        }
      }
    }).catchError((error) {
      log('❌ MenuCubit: Background refresh failed for category $categoryId: $error');
      // Don't emit error state for background operations
    });
  }

  /// Check if menu items list has changed (simple comparison by length and IDs)
  bool _itemsChanged(List<MenuItem> oldList, List<MenuItem> newList) {
    if (oldList.length != newList.length) return true;
    
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i].id != newList[i].id || 
          oldList[i].name != newList[i].name ||
          oldList[i].basePrice != newList[i].basePrice) {
        return true;
      }
    }
    return false;
  }

  /// Refresh vendor profile in background without affecting UI state
  void _refreshVendorProfileInBackground() {
    log('🍽️ MenuCubit: Refreshing vendor profile in background...');
    
    _menuRepository.getVendorProfile().then((vendor) {
      // Update cache silently
      _cachedVendorProfile = vendor;
      _lastVendorUpdate = DateTime.now();
      
      // Only emit new state if vendor data actually changed
      if (state is MenuVendorLoaded) {
        final currentVendor = (state as MenuVendorLoaded).vendor;
        if (_vendorProfileChanged(currentVendor, vendor)) {
          log('🍽️ MenuCubit: Vendor profile updated in background, refreshing UI');
          _safeEmit(MenuVendorLoaded(vendor));
        } else {
          log('🍽️ MenuCubit: Vendor profile unchanged, keeping current UI');
        }
      }
    }).catchError((error) {
      log('❌ MenuCubit: Background vendor refresh failed: $error');
      // Don't emit error state for background operations
    });
  }

  /// Check if vendor profile has changed (simple comparison by key fields)
  bool _vendorProfileChanged(dynamic oldVendor, dynamic newVendor) {
    if (oldVendor == null || newVendor == null) return true;
    
    return oldVendor.name != newVendor.name ||
           oldVendor.description != newVendor.description ||
           oldVendor.openHour != newVendor.openHour ||
           oldVendor.closeHour != newVendor.closeHour ||
           oldVendor.imagePath != newVendor.imagePath;
  }

  /// Get vendor profile
  Future<void> getVendorProfile({bool forceRefresh = false, bool showLoadingState = true}) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh && 
          _cachedVendorProfile != null && 
          _isCacheValid(_lastVendorUpdate)) {
        log('🍽️ MenuCubit: Using cached vendor profile');
        _safeEmit(MenuVendorLoaded(_cachedVendorProfile));
        return;
      }

      // If we have cached data but it's expired, show it immediately while refreshing
      if (!forceRefresh && _cachedVendorProfile != null) {
        log('🍽️ MenuCubit: Showing stale cached vendor profile while refreshing in background');
        _safeEmit(MenuVendorLoaded(_cachedVendorProfile));
        
        // Refresh in background without showing loading state
        _refreshVendorProfileInBackground();
        return;
      }

      if (showLoadingState) {
        _safeEmit(MenuLoadingVendor());
      }
      log('🍽️ MenuCubit: Loading vendor profile from API');
      
      final vendor = await _menuRepository.getVendorProfile();
      
      // Cache the result with timestamp
      _cachedVendorProfile = vendor;
      _lastVendorUpdate = DateTime.now();
      
      log('🍽️ MenuCubit: Successfully loaded vendor profile: ${vendor.name}');
      _safeEmit(MenuVendorLoaded(vendor));
    } catch (e) {
      log('❌ MenuCubit: Error loading vendor profile: $e');
      if (e.toString().contains('404') || e.toString().contains('Vendor not found')) {
        _safeEmit(MenuVendorNotFound());
      } else {
        String errorMessage = _handleError(e.toString());
        _safeEmit(MenuError(errorMessage));
      }
    }
  }

  /// Create a new menu category
  Future<void> createMenuCategory(String name, String description) async {
    try {
      _safeEmit(MenuCreatingCategory());
      log('🍽️ MenuCubit: Creating category: $name');
      
      final request = CreateMenuCategoryRequest(
        name: name,
        description: description,
      );
      
      final category = await _menuRepository.createMenuCategory(request);
      
      log('🍽️ MenuCubit: Successfully created category: ${category.name}');
      _safeEmit(MenuCategoryCreated(category));
      
      // Add to cache if it exists
      if (_cachedCategories != null) {
        _cachedCategories!.add(category);
        _lastCategoriesUpdate = DateTime.now();
      }
      
      // Reload categories to show the new one
      await loadMenuCategories(forceRefresh: true);
    } catch (e) {
      log('❌ MenuCubit: Error creating category: $e');
      String errorMessage = _handleError(e.toString());
      _safeEmit(MenuCreateCategoryError(errorMessage));
    }
  }

  /// Delete a menu category
  Future<void> deleteMenuCategory(String categoryId) async {
    try {
      _safeEmit(MenuDeletingCategory());
      log('🍽️ MenuCubit: Deleting category: $categoryId');
      
      await _menuRepository.deleteMenuCategory(categoryId);
      
      log('🍽️ MenuCubit: Successfully deleted category');
      _safeEmit(MenuCategoryDeleted(categoryId));
      
      // Remove from cache if it exists
      if (_cachedCategories != null) {
        _cachedCategories!.removeWhere((category) => category.id == categoryId);
        _lastCategoriesUpdate = DateTime.now();
      }
      
      // Also remove related items from cache
      _cachedItems.remove(categoryId);
      _lastItemsUpdate.remove(categoryId);
      
      // Reload categories to reflect the deletion
      await loadMenuCategories(forceRefresh: true);
    } catch (e) {
      log('❌ MenuCubit: Error deleting category: $e');
      String errorMessage = _handleError(e.toString());
      _safeEmit(MenuDeleteCategoryError(errorMessage));
    }
  }

  /// Load all items in a specific category
  Future<void> loadMenuItems(String categoryId, String categoryName, {bool forceRefresh = false, bool showLoadingState = true}) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh && 
          _cachedItems.containsKey(categoryId) && 
          _isCacheValid(_lastItemsUpdate[categoryId])) {
        final cachedItems = _cachedItems[categoryId]!;
        log('🍽️ MenuCubit: Using cached items for category $categoryId (${cachedItems.length} items)');
        _safeEmit(MenuItemsLoaded(cachedItems, categoryId, categoryName));
        return;
      }

      // If we have cached data but it's expired, show it immediately while refreshing
      if (!forceRefresh && _cachedItems.containsKey(categoryId)) {
        final cachedItems = _cachedItems[categoryId]!;
        log('🍽️ MenuCubit: Showing stale cached items while refreshing in background (${cachedItems.length} items)');
        _safeEmit(MenuItemsLoaded(cachedItems, categoryId, categoryName));
        
        // Refresh in background without showing loading state
        _refreshItemsInBackground(categoryId, categoryName);
        return;
      }

      if (showLoadingState) {
        _safeEmit(MenuItemsLoading());
      }
      log('🍽️ MenuCubit: Loading items for category: $categoryId from API...');
      
      final items = await _menuRepository.getItemsInCategory(categoryId);
      
      // Cache the results with timestamp
      _cachedItems[categoryId] = items;
      _lastItemsUpdate[categoryId] = DateTime.now();
      
      log('🍽️ MenuCubit: Successfully loaded ${items.length} items');
      _safeEmit(MenuItemsLoaded(items, categoryId, categoryName));
    } catch (e) {
      log('❌ MenuCubit: Error loading items: $e');
      String errorMessage = _handleError(e.toString());
      _safeEmit(MenuItemsError(errorMessage));
    }
  }

  /// Create a new menu item in a category
  Future<void> createMenuItem(
    String categoryId, 
    String name, 
    String description, 
    double basePrice, 
    int prepTime, {
    File? image,
  }) async {
    try {
      _safeEmit(MenuCreatingItem());
      log('🍽️ MenuCubit: Creating item: $name in category: $categoryId');
      log('🍽️ MenuCubit: Item details - Price: $basePrice, PrepTime: $prepTime');
      
      // Validate input parameters
      if (categoryId.isEmpty) {
        throw Exception('Category ID cannot be empty');
      }
      if (name.trim().isEmpty) {
        throw Exception('Item name cannot be empty');
      }
      if (basePrice <= 0) {
        throw Exception('Base price must be greater than 0');
      }
      if (prepTime <= 0) {
        throw Exception('Prep time must be greater than 0');
      }
      
      final request = CreateMenuItemRequest(
        name: name.trim(),
        description: description.trim(),
        basePrice: basePrice,
        prepTime: prepTime,
      );
      
      log('🍽️ MenuCubit: Sending request: ${request.toJson()}');
      final item = await _menuRepository.createMenuItem(categoryId, request, image: image);
      
      log('🍽️ MenuCubit: Successfully created item: ${item.name}');
      
      // Add to cache if it exists
      if (_cachedItems.containsKey(categoryId)) {
        _cachedItems[categoryId]!.add(item);
        _lastItemsUpdate[categoryId] = DateTime.now();
      }
      
      // Reload items to show the new one immediately
      final currentState = state;
      if (currentState is MenuItemsLoaded) {
        await loadMenuItems(categoryId, currentState.categoryName, forceRefresh: true);
      } else {
        // If we're not in MenuItemsLoaded state, find the category name and load items
        // This is a fallback in case the state is different
        try {
          final categories = await _menuRepository.getMenuCategories();
          final category = categories.firstWhere((cat) => cat.id == categoryId);
          await loadMenuItems(categoryId, category.name, forceRefresh: true);
        } catch (e) {
          log('❌ MenuCubit: Could not reload items after creation: $e');
          // Emit the created state as fallback
          _safeEmit(MenuItemCreated(item));
        }
      }
    } catch (e) {
      log('❌ MenuCubit: Error creating item: $e');
      String errorMessage = _handleError(e.toString());
      _safeEmit(MenuCreateItemError(errorMessage));
    }
  }

  /// Delete a menu item
  Future<void> deleteMenuItem(String itemId) async {
    try {
      _safeEmit(MenuDeletingItem());
      log('🍽️ MenuCubit: Deleting item: $itemId');
      
      await _menuRepository.deleteMenuItem(itemId);
      
      log('🍽️ MenuCubit: Successfully deleted item');
      
      // Remove from cache
      _cachedItems.forEach((categoryId, items) {
        final originalLength = items.length;
        items.removeWhere((item) => item.id == itemId);
        // Update timestamp if items were removed
        if (items.length != originalLength) {
          _lastItemsUpdate[categoryId] = DateTime.now();
        }
      });
      
      // Reload items to reflect the deletion immediately
      final currentState = state;
      if (currentState is MenuItemsLoaded) {
        await loadMenuItems(currentState.categoryId, currentState.categoryName, forceRefresh: true);
      } else {
        // Fallback: emit deletion state
        _safeEmit(MenuItemDeleted(itemId));
      }
    } catch (e) {
      log('❌ MenuCubit: Error deleting item: $e');
      String errorMessage = _handleError(e.toString());
      _safeEmit(MenuDeleteItemError(errorMessage));
    }
  }

  /// Navigate back to categories view
  void backToCategories() {
    log('🍽️ MenuCubit: Navigating back to categories');
    loadMenuCategories();
  }

  /// Create vendor profile for the current user
  Future<void> createVendorProfile(
    String name,
    String description,
    String categoryId,
    String openHour,
    String closeHour,
    List<String> days, {
    File? image,
  }) async {
    try {
      _safeEmit(MenuCreatingVendor());
      log('🍽️ MenuCubit: Creating vendor profile: $name');
      
      final request = CreateVendorProfileRequest(
        name: name,
        description: description,
        categoryId: categoryId,
        openHour: openHour,
        closeHour: closeHour,
        days: days,
      );
      
      final vendor = await _menuRepository.createVendorProfile(request, image: image);
      
      log('🍽️ MenuCubit: Successfully created vendor profile: ${vendor.name}');
      
      // Clear categories cache since we now have a vendor
      _cachedCategories = null;
      _lastCategoriesUpdate = null;
      
      // Load the vendor profile immediately to transition to profile view
      await loadVendorProfile();
    } catch (e) {
      log('❌ MenuCubit: Error creating vendor profile: $e');
      String errorMessage = _handleError(e.toString());
      _safeEmit(MenuCreateVendorError(errorMessage));
    }
  }

  /// Reset to initial state and clear cache
  void reset() {
    log('🍽️ MenuCubit: Resetting to initial state');
    _clearCache();
    _safeEmit(MenuInitial());
  }

  /// Force refresh all data by clearing cache
  void refreshAll() {
    log('🍽️ MenuCubit: Force refreshing all data');
    _clearCache();
    loadMenuCategories(forceRefresh: true);
  }

  @override
  Future<void> close() {
    log('🍽️ MenuCubit: Closing cubit and clearing cache');
    _clearCache();
    return super.close();
  }
}