import 'dart:developer';
import 'package:elragol_el3nab_rest/features/orders/presentation/views/widgets/orders_card.dart';
import 'package:flutter/material.dart';
import 'package:sdga_icons/sdga_icons.dart';
import '../../../../core/component/custom_drawer.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/constants/app_constants.dart';
import '../../../../core/storage/app_secure_storage.dart';
import '../../../auth/presentation/views/sign_in_view.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    final isTablet = width > 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "الطلبات",
          style: TextStyle(
            color: Colors.black,
            fontSize: width * 0.055,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: CircleAvatar(
          radius: width * 0.06,
          backgroundColor: Colors.white,
          child: Image.asset(
            AppConstants.appLogo,
            width: width * 0.1,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              radius: isTablet ? 28 : 22,
              child: IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                onPressed: () => _showLogoutDialog(context),
                tooltip: 'تسجيل الخروج',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              radius: isTablet ? 28 : 22,
              child: IconButton(
                icon: SDGAIcon(
                  SDGAIconsBulk.menu11,
                  size: isTablet ? 32 : 24,
                  color: AppColors.mainColor,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer(); // ✅ Works now
                },
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(height * 0.06),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.mainColor,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontSize: width * 0.04),
              tabs: const [
                Tab(text: "الطلبات الحالية"),
                Tab(text: "تم تنفيذها"),
                Tab(text: "الطلبات الملغاه"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// 🔹 Current Orders
          ListView(
            padding: EdgeInsets.all(width * 0.04),
            children: const [
              OrderCard(
                orderId: "#ORD-4821",
                orderTime: "اليوم - 12:30 م",
                title: "سلطة يونانية",
                price: 85.0,
                status: "قيد التحضير",
                statusColor: Colors.orange,
              ),
              OrderCard(
                orderId: "#ORD-4820",
                orderTime: "اليوم - 11:10 ص",
                title: "وجبة دايت كاملة",
                price: 120.0,
                status: "في الطريق",
                statusColor: AppColors.mainColor,
              ),
            ],
          ),

          /// 🔹 Completed Orders
          ListView(
            padding: EdgeInsets.all(width * 0.04),
            children: const [
              OrderCard(
                orderId: "#ORD-4819",
                orderTime: "أمس - 3:45 م",
                title: "باستا بالخضار",
                price: 95.5,
                status: "تم التنفيذ",
                statusColor: Colors.green,
                isCompleted: true,
              ),
              OrderCard(
                orderId: "#ORD-4818",
                orderTime: "أمس - 1:15 م",
                title: "بيتزا مارغريتا",
                price: 110.0,
                status: "تم التنفيذ",
                statusColor: Colors.green,
                isCompleted: true,
              ),
            ],
          ),

          /// 🔹 Cancelled Orders
          ListView(
            padding: EdgeInsets.all(width * 0.04),
            children: const [
              OrderCard(
                orderId: "#ORD-4817",
                orderTime: "15 أكتوبر - 8:00 م",
                title: "ساندوتش تونة",
                price: 60.0,
                status: "تم الإلغاء",
                statusColor: Colors.red,
              ),
              OrderCard(
                orderId: "#ORD-4816",
                orderTime: "14 أكتوبر - 9:45 م",
                title: "وجبة كيتو",
                price: 130.0,
                status: "تم الإلغاء",
                statusColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing during logout
      builder: (dialogContext) => _LogoutDialog(
        onLogout: () async {
          await _performLogout(context); // Use original context, not dialog context
        },
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    // First, close the dialog to free up the context
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    
    try {
      log('🔄 Starting logout process...');
      
      // Clear data with timeout
      await AppPreferences.clearAll().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          log('⚠️ Logout timeout - proceeding anyway');
        },
      );
      
      log('✅ Logout data cleared successfully');
      
    } catch (e) {
      log('❌ Logout error: $e');
    }
    
    // Navigate immediately after clearing data
    log('🔍 Checking navigation conditions: mounted=$mounted, context.mounted=${context.mounted}');
    
    // Give a small delay for the dialog to close completely
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (mounted && context.mounted) {
      log('🔄 Navigating to sign in screen...');
      
      try {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
            log('✅ SignInView constructor called');
            return const SignInView();
          }),
          (route) {
            log('🔍 Removing route: ${route.settings.name}');
            return false;
          },
        );
        log('✅ Navigation completed successfully');
      } catch (navError) {
        log('❌ Navigation error: $navError - trying root navigator');
        
        try {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignInView()),
            (route) => false,
          );
          log('✅ Root navigator navigation completed');
        } catch (rootError) {
          log('❌ Root navigator failed: $rootError');
        }
      }
    } else {
      log('❌ Context not mounted, cannot navigate. mounted=$mounted, context.mounted=${context.mounted}');
    }
  }
}

class _LogoutDialog extends StatefulWidget {
  final Future<void> Function() onLogout;

  const _LogoutDialog({required this.onLogout});

  @override
  State<_LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<_LogoutDialog> {
  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'تأكيد تسجيل الخروج',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: isLoggingOut
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.mainColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'جاري تسجيل الخروج...',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Force logout - close dialog first, then clear data and navigate
                    Navigator.of(context).pop();
                    
                    AppPreferences.clearAll().then((_) {
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const SignInView()),
                          (route) => false,
                        );
                      }
                    }).catchError((e) {
                      // Even if clearing fails, navigate anyway
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const SignInView()),
                          (route) => false,
                        );
                      }
                    });
                  },
                  child: const Text(
                    'فرض تسجيل الخروج',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            )
          : const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
      actions: isLoggingOut
          ? null
          : [
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
                onPressed: () async {
                  if (isLoggingOut) return; // Prevent multiple clicks
                  
                  setState(() {
                    isLoggingOut = true;
                  });
                  
                  // Add a small delay to show loading state
                  await Future.delayed(const Duration(milliseconds: 300));
                  
                  // Close dialog first to avoid navigation conflicts
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                  
                  // Then perform logout with a small delay to ensure dialog is closed
                  await Future.delayed(const Duration(milliseconds: 100));
                  
                  try {
                    await widget.onLogout();
                  } catch (e) {
                    log('❌ Logout dialog error: $e');
                  }
                },
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
    );
  }
}
