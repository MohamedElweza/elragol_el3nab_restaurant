import 'package:flutter/material.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final String orderTime;
  final String title;
  final double price;
  final String status;
  final Color statusColor;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.orderTime,
    required this.title,
    required this.price,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "تفاصيل الطلب",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.mainColor),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🧾 Order ID & Status
              Card(
                color: Colors.grey[100],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow("رقم الطلب:", orderId, width),
                      SizedBox(height: height * 0.01),
                      _buildRow("تاريخ الطلب:", orderTime, width),
                      SizedBox(height: height * 0.02),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: width * 0.03, vertical: height * 0.005),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.025),

              /// 👤 Customer Info
              Text("بيانات العميل",
                  style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: height * 0.01),
              Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(width * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow("الاسم:", "محمد أحمد", width),
                      _buildRow("رقم الهاتف:", "01012345678", width),
                      _buildRow("العنوان:", "القاهرة، مصر", width),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.025),

              /// 🍽 Items
              Text("المنتجات",
                  style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              SizedBox(height: height * 0.01),
              Card(
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(width * 0.04),
                  child: Column(
                    children: [
                      _buildItem("سلطة يونانية", 1, 85),
                      _buildItem("مشروب طاقة", 2, 40),
                      _buildItem("بيتزا مارغريتا", 1, 110),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.025),

              /// 💰 Total
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "الإجمالي: ${(price + 150).toStringAsFixed(2)} EGP",
                  style: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainColor,
                  ),
                ),
              ),

              SizedBox(height: height * 0.04),

              /// 🚚 Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.mainColor),
                        padding: EdgeInsets.symmetric(vertical: height * 0.018),
                      ),
                      child: Text("تتبع الطلب",
                          style: TextStyle(
                              color: AppColors.mainColor,
                              fontSize: width * 0.04)),
                    ),
                  ),
                  SizedBox(width: width * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppColors.mainColor,
                        padding: EdgeInsets.symmetric(vertical: height * 0.018),
                      ),
                      child: Text("اتصل بالعميل",
                          style: TextStyle(
                              color: Colors.white, fontSize: width * 0.04)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value, double width) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: width * 0.04,
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: width * 0.04, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String name, int quantity, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16))),
          Text("x$quantity", style: const TextStyle(color: Colors.grey)),
          Text("${price.toStringAsFixed(2)} EGP",
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
