import 'package:flutter/material.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';
import '../../../data/models/menu_item.dart';
import '../../../../../core/utils/image_picker_helper.dart';

class ItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 12),
            child: ImagePickerHelper.buildImageWidget(
              imagePath: item.imagePath,
              placeholderType: 'food',
              width: 80,
              height: 80,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          // Item Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and delete button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
            
            // Description
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Price and prep time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.basePrice.toStringAsFixed(2)} جنيه',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.prepTime} دقيقة',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Status indicators
            Row(
              children: [
                // Active status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.isActive 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.isActive ? 'نشط' : 'غير نشط',
                    style: TextStyle(
                      fontSize: 11,
                      color: item.isActive 
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Available status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.isAvailable 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.isAvailable ? 'متاح' : 'غير متاح',
                    style: TextStyle(
                      fontSize: 11,
                      color: item.isAvailable 
                          ? Colors.green[700]
                          : Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Order
                Text(
                  'الترتيب: ${item.order}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            
            // Discount information if available
            if (item.discount != null && item.discount!.isActive) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_offer,
                      size: 14,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'خصم ${item.discount!.value}${item.discount!.type == 'percentage' ? '%' : ' جنيه'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}