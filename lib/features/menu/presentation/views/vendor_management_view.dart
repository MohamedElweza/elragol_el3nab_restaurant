import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/menu_cubit.dart';
import '../../cubit/menu_state.dart';
import '../../cubit/global_menu_provider.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import 'widgets/menu_categories_view_body.dart';
import 'widgets/menu_items_view_body.dart';
import '../components/create_vendor_dialog.dart';
import 'vendor_profile_view.dart';

class VendorManagementView extends StatelessWidget {
  const VendorManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GlobalMenuProvider.getInstance(),
      child: Builder(
        builder: (context) {
          // Load vendor profile with the global instance
          // This will use cache and preload categories for better performance
          context.read<MenuCubit>().loadVendorProfile();
          return const VendorManagementViewBody();
        },
      ),
    );
  }
}

class VendorManagementViewBody extends StatefulWidget {
  const VendorManagementViewBody({super.key});

  @override
  State<VendorManagementViewBody> createState() => _VendorManagementViewBodyState();
}

class _VendorManagementViewBodyState extends State<VendorManagementViewBody> {
  bool _isCreatingVendor = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MenuCubit, MenuState>(
      listener: (context, state) {
        if (state is MenuError) {
          _isCreatingVendor = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is MenuCreatingVendor) {
          _isCreatingVendor = true;
        } else if (state is MenuVendorLoaded && _isCreatingVendor) {
          _isCreatingVendor = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء ملف المطعم بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MenuInitial || state is MenuLoadingVendor || state is MenuCategoriesLoading) {
          return const _LoadingView();
        }
        
        if (state is MenuVendorNotFound) {
          return _VendorSetupView(
            onVendorCreating: () {
              setState(() {
                _isCreatingVendor = true;
              });
            },
          );
        }
        
        if (state is MenuVendorLoaded) {
          // Navigate to the existing VendorProfileView which has better UI
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const VendorProfileView(),
              ),
            );
          });
          return const _LoadingView();
        }
        
        if (state is MenuCategoriesLoaded) {
          return const MenuCategoriesViewBody();
        }
        
        if (state is MenuItemsLoaded) {
          return MenuItemsViewBody(
            categoryId: state.categoryId,
            categoryName: state.categoryName,
          );
        }
        
        if (state is MenuCategoriesError || state is MenuError) {
          final message = state is MenuCategoriesError ? state.message : (state as MenuError).message;
          return _ErrorView(
            message: message,
            onRetry: () => context.read<MenuCubit>().loadVendorProfile(),
          );
        }
        
        // Fallback to loading view
        return const _LoadingView();
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة المطعم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.mainColor),
            SizedBox(height: 16),
            Text(
              'جارٍ تحميل بيانات المطعم...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorSetupView extends StatelessWidget {
  final VoidCallback onVendorCreating;
  
  const _VendorSetupView({required this.onVendorCreating});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إعداد المطعم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store_outlined,
                size: 120,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'مرحباً بك!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'لم يتم إعداد ملف المطعم الخاص بك بعد.\nيرجى إنشاء ملف المطعم للبدء في إدارة المنيو والطلبات.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _showCreateVendorDialog(context, onVendorCreating),
                icon: const Icon(Icons.add_business, color: Colors.white),
                label: const Text(
                  'إنشاء ملف المطعم',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.read<MenuCubit>().loadVendorProfile(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: AppColors.mainColor),
                    const SizedBox(width: 8),
                    Text(
                      'إعادة فحص البيانات',
                      style: TextStyle(color: AppColors.mainColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateVendorDialog(BuildContext context, Function() onVendorCreating) {
    // Get the MenuCubit instance before showing the dialog
    final menuCubit = context.read<MenuCubit>();
    
    // Get the MenuRepository from the MenuCubit
    final menuRepository = menuCubit.repository;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: menuCubit,
        child: CreateVendorDialog(
          menuRepository: menuRepository,
          onCreateVendor: (name, description, categoryId, openHour, closeHour, days, {image}) {
            // Notify that we're starting vendor creation
            onVendorCreating();
            // Use the captured menuCubit instance directly instead of trying to read from context
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
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة المطعم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 120,
                color: Colors.red[400],
              ),
              const SizedBox(height: 24),
              Text(
                'حدث خطأ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}