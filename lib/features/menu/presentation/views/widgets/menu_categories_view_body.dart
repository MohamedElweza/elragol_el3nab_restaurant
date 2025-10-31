import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';
import '../../../cubit/menu_cubit.dart';
import '../../../cubit/menu_state.dart';
import '../../../data/models/menu_category.dart';
import '../menu_items_view.dart';
import '../vendor_setup_view.dart';
import 'category_card.dart';
import 'add_category_dialog.dart';
import '../../components/create_vendor_dialog.dart';
import '../../components/skeleton_loader.dart';

class MenuCategoriesViewBody extends StatelessWidget {
  const MenuCategoriesViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة القوائم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.white),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<MenuCubit, MenuState>(
        listener: (context, state) {
          if (state is MenuVendorNotFound) {
            // Navigate to vendor setup instead of showing dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const VendorSetupView(),
              ),
            );
          } else if (state is MenuVendorCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إنشاء ملف المطعم بنجاح: ${state.vendor.name}'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MenuCreateVendorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MenuCategoriesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MenuCreateCategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MenuDeleteCategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MenuCategoryCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إنشاء القسم بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MenuCategoryDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حذف القسم بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MenuCategoriesLoading || state is MenuCreatingVendor) {
            return Column(
              children: [
                // Show a subtle loading indicator at the top
                if (state is MenuCategoriesLoading)
                  Container(
                    height: 3,
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
                    ),
                  ),
                // Show skeleton loader for better UX
                Expanded(
                  child: state is MenuCreatingVendor
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: AppColors.mainColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'جاري إنشاء ملف المطعم...',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : const CategoriesSkeletonLoader(),
                ),
              ],
            );
          }

          if (state is MenuVendorNotFound) {
            return _buildVendorNotFoundState(context);
          }

          if (state is MenuCategoriesLoaded) {
            if (state.categories.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MenuCubit>().loadMenuCategories(forceRefresh: true);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return CategoryCard(
                    category: category,
                    onTap: () => _navigateToItems(context, category),
                    onDelete: () => _showDeleteConfirmation(context, category),
                  );
                },
              ),
            );
          }

          if (state is MenuCategoriesError) {
            return _buildErrorState(context, state.message);
          }

          return const Center(
            child: Text('مرحباً بك في إدارة القوائم'),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أقسام في القائمة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على زر + لإضافة قسم جديد',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('إضافة قسم جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<MenuCubit>().loadMenuCategories(forceRefresh: true);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final cubit = context.read<MenuCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: const AddCategoryDialog(),
      ),
    );
  }

  void _navigateToItems(BuildContext context, MenuCategory category) {
    final menuCubit = context.read<MenuCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (buildContext) => BlocProvider.value(
          value: menuCubit,
          child: MenuItemsView(
            categoryId: category.id,
            categoryName: category.name,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MenuCategory category) {
    final cubit = context.read<MenuCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف قسم "${category.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.deleteMenuCategory(category.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 100,
            color: Colors.orange[400],
          ),
          const SizedBox(height: 16),
          Text(
            'ملف المطعم غير موجود',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.orange[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يجب إنشاء ملف المطعم أولاً لتتمكن من إدارة القوائم والأصناف',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateVendorDialog(context),
            icon: const Icon(Icons.add_business),
            label: const Text('إنشاء ملف المطعم'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateVendorDialog(BuildContext context) {
    final menuCubit = context.read<MenuCubit>();
    final menuRepository = menuCubit.repository;
    
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing without action
      builder: (dialogContext) => CreateVendorDialog(
        menuRepository: menuRepository,
        onCreateVendor: (name, description, categoryId, openHour, closeHour, days, {image}) {
          menuCubit.createVendorProfile(
            name,
            description,
            categoryId,
            openHour,
            closeHour,
            days,
            image: image,
          );
        },
      ),
    );
  }
}