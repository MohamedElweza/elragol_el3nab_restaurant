import 'package:flutter/material.dart';
import '../../../../core/component/custom_drawer.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/constants/app_constants.dart';
import '../../../orders/presentation/views/orders_screen.dart';
import '../../../menu/presentation/views/vendor_management_view.dart';
import '../../../menu/presentation/views/vendor_setup_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "الرئيسية",
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.055,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: CircleAvatar(
              radius: width * 0.06,
              backgroundColor: Colors.white,
              child: Image.asset(
                AppConstants.appLogo,
                width: width * 0.1,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              radius: 22,
              child: IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: AppColors.mainColor,
                ),
                onPressed: () {
                  // Handle notifications
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.mainColor, AppColors.mainColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك في',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.045,
                    ),
                  ),
                  Text(
                    AppConstants.appTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إدارة مطعمك بسهولة وكفاءة',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: width * 0.035,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.03),

            // Quick Actions Grid
            Text(
              'الخدمات السريعة',
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: height * 0.02),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.restaurant_menu,
                  title: 'إدارة المنيو',
                  subtitle: 'إضافة وتعديل الأصناف',
                  color: Colors.orange,
                  onTap: () => _navigateToVendorManagement(context),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.shopping_bag,
                  title: 'الطلبات',
                  subtitle: 'متابعة طلبات العملاء',
                  color: Colors.blue,
                  onTap: () => _navigateToOrders(context),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.store,
                  title: 'إعداد المطعم',
                  subtitle: 'تعديل بيانات المطعم',
                  color: Colors.green,
                  onTap: () => _navigateToVendorSetup(context),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.analytics,
                  title: 'التقارير',
                  subtitle: 'مراجعة الأداء والمبيعات',
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('قريباً...')),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: height * 0.03),

            // Statistics Cards
            Text(
              'إحصائيات سريعة',
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: height * 0.02),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.shopping_cart,
                    title: 'طلبات اليوم',
                    value: '12',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.attach_money,
                    title: 'المبيعات',
                    value: '1,250 ر.س',
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            SizedBox(height: height * 0.02),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.trending_up,
                    title: 'نسبة النمو',
                    value: '+15%',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star,
                    title: 'التقييم',
                    value: '4.5',
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToVendorManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VendorManagementView(),
      ),
    );
  }

  void _navigateToOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrdersScreen(),
      ),
    );
  }

  void _navigateToVendorSetup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VendorSetupView(),
      ),
    );
  }
}