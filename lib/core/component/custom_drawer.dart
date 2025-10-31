import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:elragol_el3nab_rest/features/profile/presentation/views/profile_view.dart';
import '../utils/app_colors/app_colors.dart';
import '../utils/constants/app_constants.dart';
import '../../features/menu/presentation/views/vendor_management_view.dart';
import '../../features/menu/presentation/views/auth_debug_view.dart';

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

              // _buildDrawerItem(
              //   context,
              //   Icons.store_outlined,
              //   "إعداد المطعم",
              //       () {
              //     Navigator.pop(context);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (_) => const VendorSetupView()),
              //     );
              //   },
              // ),

              _buildDrawerItem(
                context,
                Icons.restaurant_menu_outlined,
                "إدارة المنيو",
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VendorManagementView()),
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

              _buildDrawerItem(
                context,
                Icons.bug_report_outlined,
                "فحص المصادقة",
                    () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthDebugView(),
                  ),
                ),
              ),

              const Spacer(),
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

}
