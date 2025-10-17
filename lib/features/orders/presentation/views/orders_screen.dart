import 'package:elragol_el3nab_rest/features/orders/presentation/views/widgets/orders_card.dart';
import 'package:flutter/material.dart';
import 'package:sdga_icons/sdga_icons.dart';
import '../../../../core/component/custom_drawer.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/constants/app_constants.dart';

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
}
