import 'package:flutter/material.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';
import '../order_details_screen.dart';


class OrderCard extends StatelessWidget {
  final String orderId;
  final String orderTime;
  final String title;
  final double price;
  final String status;
  final Color statusColor;
  final bool isCompleted;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.orderTime,
    required this.title,
    required this.price,
    required this.status,
    required this.statusColor,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(
              orderId: orderId,
              orderTime: orderTime,
              title: title,
              price: price,
              status: status,
              statusColor: statusColor,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: EdgeInsets.only(bottom: height * 0.02),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.2),
        child: Padding(
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Header Row (Order ID + Time)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    orderId,
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    orderTime,
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.01),

              /// 🔹 Title + Price + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    "${price.toStringAsFixed(2)} EGP",
                    style: TextStyle(
                      color: AppColors.mainColor,
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.01),

              /// 🔹 Status Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: height * 0.005,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
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
