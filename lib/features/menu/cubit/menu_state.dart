import '../data/models/menu_category.dart';
import '../data/models/menu_item.dart';
import '../data/models/vendor_profile.dart';

abstract class MenuState {
  const MenuState();
}

// Initial state
class MenuInitial extends MenuState {}

// Loading states
class MenuCategoriesLoading extends MenuState {}

class MenuItemsLoading extends MenuState {}

class MenuCreatingCategory extends MenuState {}

class MenuCreatingItem extends MenuState {}

class MenuDeletingCategory extends MenuState {}

class MenuDeletingItem extends MenuState {}

// Success states
class MenuCategoriesLoaded extends MenuState {
  final List<MenuCategory> categories;

  const MenuCategoriesLoaded(this.categories);
}

class MenuItemsLoaded extends MenuState {
  final List<MenuItem> items;
  final String categoryId;
  final String categoryName;

  const MenuItemsLoaded(this.items, this.categoryId, this.categoryName);
}

class MenuCategoryCreated extends MenuState {
  final MenuCategory category;

  const MenuCategoryCreated(this.category);
}

class MenuItemCreated extends MenuState {
  final MenuItem item;

  const MenuItemCreated(this.item);
}

class MenuCategoryDeleted extends MenuState {
  final String categoryId;

  const MenuCategoryDeleted(this.categoryId);
}

class MenuItemDeleted extends MenuState {
  final String itemId;

  const MenuItemDeleted(this.itemId);
}

// Error states
class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);
}

class MenuCategoriesError extends MenuError {
  const MenuCategoriesError(super.message);
}

class MenuItemsError extends MenuError {
  const MenuItemsError(super.message);
}

class MenuCreateCategoryError extends MenuError {
  const MenuCreateCategoryError(super.message);
}

class MenuCreateItemError extends MenuError {
  const MenuCreateItemError(super.message);
}

class MenuDeleteCategoryError extends MenuError {
  const MenuDeleteCategoryError(super.message);
}

class MenuDeleteItemError extends MenuError {
  const MenuDeleteItemError(super.message);
}

// Vendor states
class MenuLoadingVendor extends MenuState {}

class MenuVendorLoaded extends MenuState {
  final VendorProfile vendor;

  const MenuVendorLoaded(this.vendor);
}

class MenuVendorNotFound extends MenuState {
  const MenuVendorNotFound();
}

class MenuCreatingVendor extends MenuState {}

class MenuVendorCreated extends MenuState {
  final VendorProfile vendor;

  const MenuVendorCreated(this.vendor);
}

class MenuCreateVendorError extends MenuError {
  const MenuCreateVendorError(super.message);
}