import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../menu/presentation/views/menu_management_view.dart';

class VendorCreatedSuccessView extends StatelessWidget {
  final String vendorName;
  
  const VendorCreatedSuccessView({
    super.key,
    required this.vendorName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.mainColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 32),

            // Success message
            Text(
              'تم إنشاء ملف المطعم بنجاح!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Vendor name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.mainColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.store,
                    color: AppColors.mainColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vendorName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Next steps
            Text(
              'الخطوات التالية:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.mainColor,
              ),
            ),
            const SizedBox(height: 20),

            _buildNextStep(
              context,
              icon: Icons.category_outlined,
              title: 'إضافة أقسام القائمة',
              description: 'مثل: المقبلات، الأطباق الرئيسية، المشروبات، الحلويات',
            ),
            const SizedBox(height: 16),

            _buildNextStep(
              context,
              icon: Icons.restaurant_outlined,
              title: 'إضافة الأصناف والأطباق',
              description: 'إضافة الوجبات والمشروبات مع الأسعار وأوقات التحضير',
            ),
            const SizedBox(height: 16),

            _buildNextStep(
              context,
              icon: Icons.visibility_outlined,
              title: 'مراجعة القائمة',
              description: 'التأكد من صحة جميع البيانات وتفعيل القائمة للعملاء',
            ),
            const SizedBox(height: 40),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MenuManagementView(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text(
                  'ابدأ إدارة القوائم',
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

            // Skip for now button
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(
                'تخطي الآن - العودة للرئيسية',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStep(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.mainColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}