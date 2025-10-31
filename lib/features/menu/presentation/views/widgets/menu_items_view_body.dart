import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';
import '../../../cubit/menu_cubit.dart';
import '../../../cubit/menu_state.dart';
import '../../../data/models/menu_item.dart';
import 'item_card.dart';
import 'add_item_dialog.dart';
import '../../components/skeleton_loader.dart';

class MenuItemsViewBody extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const MenuItemsViewBody({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoryName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            context.read<MenuCubit>().backToCategories();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.white),
            onPressed: () => _showAddItemDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<MenuCubit, MenuState>(
        listener: (context, state) {
          if (state is MenuItemsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MenuCreateItemError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MenuDeleteItemError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MenuItemCreated) {
            // This is now only used as fallback
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إضافة الصنف بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MenuItemDeleted) {
            // This is now only used as fallback
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حذف الصنف بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MenuItemsLoading) {
            return Column(
              children: [
                // Show a subtle loading indicator at the top
                Container(
                  height: 3,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
                  ),
                ),
                // Show skeleton loader for better UX
                const Expanded(
                  child: MenuItemsSkeletonLoader(),
                ),
              ],
            );
          }

          if (state is MenuItemsLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                // Use force refresh for manual pull-to-refresh
                final completer = Completer<void>();
                final cubit = context.read<MenuCubit>();
                
                // Listen for the refresh completion
                late StreamSubscription subscription;
                subscription = cubit.stream.listen((newState) {
                  if (newState is MenuItemsLoaded && newState.categoryId == categoryId) {
                    subscription.cancel();
                    completer.complete();
                  } else if (newState is MenuItemsError) {
                    subscription.cancel();
                    completer.complete();
                  }
                });
                
                cubit.loadMenuItems(categoryId, categoryName, forceRefresh: true);
                return completer.future;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ItemCard(
                    item: item,
                    onDelete: () => _showDeleteConfirmation(context, item),
                  );
                },
              ),
            );
          }

          if (state is MenuItemsError) {
            return _buildErrorState(context, state.message);
          }

          // If we're not in items state, show skeleton loading
          return const MenuItemsSkeletonLoader();
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
            Icons.fastfood_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أصناف في هذا القسم',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على زر + لإضافة صنف جديد',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('إضافة صنف جديد'),
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
              context.read<MenuCubit>().loadMenuItems(categoryId, categoryName, forceRefresh: true);
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

  void _showAddItemDialog(BuildContext context) {
    final cubit = context.read<MenuCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AddItemDialog(categoryId: categoryId),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MenuItem item) {
    final cubit = context.read<MenuCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف "${item.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.deleteMenuItem(item.id);
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
}