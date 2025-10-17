import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:elragol_el3nab_rest/features/profile/presentation/views/profile_view.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';
import '../../../../../core/utils/constants/app_constants.dart';
import '../../features/menu.dart';
import '../../features/menu/presentation/views/menu.dart';

@immutable
class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      child: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.mainColor,
                AppColors.mainColor.withOpacity(.5),
              ],
            ),
          ),
          child: Column(
            children: <Widget>[
              _buildHeader(context, screenHeight),

              _buildDrawerItem(
                context,
                Icons.person_outline,
                "الملف الشخصي",
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileView()),
                  );
                },
              ),

              _buildDrawerItem(
                context,
                Icons.restaurant_menu_outlined,
                "إدارة المنيو",
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MenuScreen()),
                  );
                },
              ),

              _buildDrawerItem(
                context,
                Icons.notifications_outlined,
                "الإشعارات",
                    () => log("فتح الإشعارات"),
              ),

              _buildDrawerItem(
                context,
                Icons.description_outlined,
                "الشروط و الأحكام",
                    () => log("فتح الشروط والأحكام"),
              ),

              _buildDrawerItem(
                context,
                Icons.support_agent_outlined,
                "الدعم الفني",
                    () => log("فتح الدعم الفني"),
              ),

              const Spacer(),
              _buildLogoutButton(context),
              _buildCopyright(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double screenHeight) {
    return Container(
      height: screenHeight * 0.25,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.white.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.white,
              backgroundImage: AssetImage(AppConstants.appLogo),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              AppConstants.appTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.025,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'هيوصلك لحد الباب',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontSize: screenHeight * 0.015,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.white),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: AppColors.white.withOpacity(0.1),
      focusColor: AppColors.white.withOpacity(0.1),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: Text(
          "تسجيل الخروج",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainColor.withOpacity(.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size.fromHeight(50),
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: AppColors.mainColor.withOpacity(0.7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.copyright, size: 16, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            '${DateTime.now().year} ${AppConstants.appTitle}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تأكيد تسجيل الخروج',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
