import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/token_interceptor.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../cubit/menu_cubit.dart';
import '../../cubit/menu_state.dart';
import '../../data/repos/menu_repository.dart';
import '../components/create_vendor_dialog.dart';
import 'vendor_created_success_view.dart';

class VendorSetupView extends StatelessWidget {
  const VendorSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        // Create Dio instance with token interceptor
        final dio = Dio();
        dio.interceptors.add(TokenInterceptor());
        
        // Create repository and cubit
        final repository = MenuRepository(dio: dio);
        final cubit = MenuCubit(repository);
        
        // Check vendor status immediately
        cubit.loadMenuCategories(); // This will trigger vendor check
        
        return cubit;
      },
      child: const VendorSetupViewBody(),
    );
  }
}

class VendorSetupViewBody extends StatelessWidget {
  const VendorSetupViewBody({super.key});

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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<MenuCubit, MenuState>(
        listener: (context, state) {
          if (state is MenuVendorCreated) {
            // Navigate to success screen after vendor creation
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VendorCreatedSuccessView(
                  vendorName: state.vendor.name,
                ),
              ),
            );
          } else if (state is MenuCreateVendorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MenuCategoriesLoaded) {
            // If categories loaded successfully, vendor exists
            Navigator.pushReplacementNamed(context, '/menu_management');
          }
        },
        builder: (context, state) {
          if (state is MenuCategoriesLoading || state is MenuCreatingVendor) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.mainColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state is MenuCreatingVendor 
                        ? 'جاري إنشاء ملف المطعم...' 
                        : 'جاري فحص بيانات المطعم...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is MenuVendorNotFound) {
            return _buildVendorSetupContent(context);
          }

          if (state is MenuCategoriesError) {
            return _buildErrorState(context, state.message);
          }

          // Default loading state
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.mainColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorSetupContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main illustration
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_outlined,
              size: 80,
              color: AppColors.mainColor,
            ),
          ),
          const SizedBox(height: 32),

          // Welcome title
          Text(
            'مرحباً بك في إدارة المطعم!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.mainColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'لبدء إدارة قوائم الطعام والأصناف، يجب إنشاء ملف المطعم أولاً.\nسيتضمن الملف معلومات أساسية عن مطعمك مثل الاسم والوصف والموقع.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Steps preview
          _buildStepsPreview(context),
          const SizedBox(height: 40),

          // Create vendor button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateVendorDialog(context),
              icon: const Icon(Icons.add_business, color: Colors.white),
              label: const Text(
                'إنشاء ملف المطعم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Refresh button
          TextButton.icon(
            onPressed: () {
              context.read<MenuCubit>().loadMenuCategories();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('فحص البيانات مرة أخرى'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsPreview(BuildContext context) {
    return Column(
      children: [
        Text(
          'الخطوات التالية:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.mainColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildStep(
          context,
          number: '1',
          title: 'إنشاء ملف المطعم',
          description: 'إدخال معلومات المطعم الأساسية',
          isActive: true,
        ),
        _buildStep(
          context,
          number: '2',
          title: 'إضافة أقسام القائمة',
          description: 'مثل: المقبلات، الأطباق الرئيسية، الحلويات',
          isActive: false,
        ),
        _buildStep(
          context,
          number: '3',
          title: 'إضافة الأصناف',
          description: 'إضافة الأطباق والمشروبات لكل قسم',
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? AppColors.mainColor : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive ? AppColors.mainColor : Colors.grey[700],
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[600],
                fontWeight: FontWeight.bold,
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
                context.read<MenuCubit>().loadMenuCategories();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateVendorDialog(BuildContext context) {
    final menuCubit = context.read<MenuCubit>();
    final menuRepository = menuCubit.repository;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CreateVendorDialog(
        menuRepository: menuRepository,
        onCreateVendor: (name, description, categoryId, openHour, closeHour, days, {image}) {
          log('🍽️ VendorSetupView: Creating vendor profile: $name');
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