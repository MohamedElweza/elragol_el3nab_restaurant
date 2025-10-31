import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../../core/errors/token_interceptor.dart';
import '../../../../../core/utils/image_picker_helper.dart';
import '../../cubit/menu_cubit.dart';
import '../../cubit/menu_state.dart';
import '../../cubit/global_menu_provider.dart';
import '../../data/repos/menu_repository.dart';
import '../components/skeleton_loader.dart';

import 'menu_management_view.dart';

class VendorProfileView extends StatefulWidget {
  const VendorProfileView({super.key});

  @override
  State<VendorProfileView> createState() => _VendorProfileViewState();
}

class _VendorProfileViewState extends State<VendorProfileView> {
  @override
  void initState() {
    super.initState();
    // Load vendor profile only once when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = GlobalMenuProvider.getInstance();
      // Only load if we don't already have vendor data
      if (cubit.state is! MenuVendorLoaded) {
        cubit.getVendorProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: GlobalMenuProvider.getInstance(),
      child: const VendorProfileViewBody(),
    );
  }
}

class VendorProfileViewBody extends StatelessWidget {
  const VendorProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'ملف المطعم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: BlocConsumer<MenuCubit, MenuState>(
        listener: (context, state) {
          if (state is MenuError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MenuLoadingVendor) {
            return const VendorProfileSkeleton();
          }
          
          if (state is MenuVendorLoaded) {
            final vendor = state.vendor;
            
            return RefreshIndicator(
              onRefresh: () async {
                final completer = Completer<void>();
                final cubit = context.read<MenuCubit>();
                
                // Listen for the refresh completion
                late StreamSubscription subscription;
                subscription = cubit.stream.listen((newState) {
                  if (newState is MenuVendorLoaded) {
                    subscription.cancel();
                    completer.complete();
                  } else if (newState is MenuError) {
                    subscription.cancel();
                    completer.complete();
                  }
                });
                
                cubit.getVendorProfile(forceRefresh: true);
                return completer.future;
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Vendor Image Card
                  Card(
                    elevation: 4,
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    
                    ),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.mainColor.withOpacity(0.8),
                            AppColors.mainColor,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background Image
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: vendor.logoPath != null && vendor.logoPath!.isNotEmpty
                                  ? Image.network(
                                      ImagePickerHelper.getVendorLogoUrl(vendor.logoPath),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return ImagePickerHelper.buildImageWidget(
                                          imagePath: null,
                                          placeholderType: 'vendor',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                    )
                                  : ImagePickerHelper.buildImageWidget(
                                      imagePath: null,
                                      placeholderType: 'vendor',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          // Gradient Overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Edit Logo Button
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                onPressed: () => _showLogoUploadDialog(context),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                                tooltip: 'تغيير شعار المطعم',
                              ),
                            ),
                          ),
                          // Vendor Name
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendor.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vendor.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.white.withOpacity(0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Vendor Details Card
                  Card(
                    elevation: 2,
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تفاصيل المطعم',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Working Hours
                          _buildInfoRow(
                            icon: Icons.access_time,
                            title: 'ساعات العمل',
                            content: '${vendor.workingHours.open} - ${vendor.workingHours.close}',
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Working Days
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            title: 'أيام العمل',
                            content: _getWorkingDaysInArabic(vendor.workingHours.days),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Status
                          _buildInfoRow(
                            icon: vendor.isActive ? Icons.check_circle : Icons.cancel,
                            title: 'الحالة',
                            content: vendor.isActive ? 'نشط' : 'غير نشط',
                            contentColor: vendor.isActive ? Colors.green : Colors.red,
                          ),
                          
                          if (vendor.averageRate != null) ...[
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              icon: Icons.star,
                              title: 'التقييم',
                              content: '${vendor.averageRate!.toStringAsFixed(1)} (${vendor.totalRates ?? 0} تقييم)',
                              contentColor: Colors.amber,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Management Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MenuManagementView(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'إدارة الأصناف',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ),
            );
          }
          
          if (state is MenuVendorNotFound) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لم يتم إنشاء ملف المطعم بعد',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يجب إنشاء ملف المطعم أولاً لإدارة القوائم',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'العودة للقائمة الرئيسية',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          // Default error state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                const Text(
                  'حدث خطأ في تحميل بيانات المطعم',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<MenuCubit>().getVendorProfile();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    Color? contentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.mainColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: contentColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getWorkingDaysInArabic(List<String> days) {
    final Map<String, String> dayTranslations = {
      'Monday': 'الاثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
    };

    return days
        .map((day) => dayTranslations[day] ?? day)
        .join(', ');
  }

  void _showLogoUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'تغيير شعار المطعم',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر طريقة رفع الشعار الجديد',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة من الكاميرا'),
              onTap: () async {
                Navigator.of(dialogContext).pop();
                await _uploadLogo(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.of(dialogContext).pop();
                await _uploadLogo(context, ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadLogo(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('جارٍ رفع الشعار...'),
              ],
            ),
          ),
        );

        // Get current vendor to get vendor ID
        final cubit = context.read<MenuCubit>();
        final currentState = cubit.state;
        
        if (currentState is MenuVendorLoaded) {
          // Create a new repository instance with TokenInterceptor
          final dio = Dio();
          dio.interceptors.add(TokenInterceptor());
          final repository = MenuRepository(dio: dio);
          
          await repository.uploadVendorLogo(currentState.vendor.id, file);
          
          // Close loading dialog
          Navigator.of(context).pop();
          
          // Refresh vendor profile (force refresh to get updated logo)
          cubit.getVendorProfile(forceRefresh: true);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفع الشعار بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Close loading dialog
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('خطأ: لم يتم العثور على بيانات المطعم'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في رفع الشعار: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}