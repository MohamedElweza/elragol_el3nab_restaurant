import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';

class CategoryItemsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryItemsScreen({super.key, required this.categoryName});

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final List<Map<String, dynamic>> items = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  File? selectedImage;

  /// Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  /// Add or Edit item dialog
  void _showAddOrEditItemDialog({Map<String, dynamic>? item, int? index}) {
    final isEdit = item != null;
    nameController.text = item?['name'] ?? '';
    descController.text = item?['description'] ?? '';
    priceController.text = item?['price']?.toString() ?? '';
    selectedImage = item?['image'] != null ? File(item!['image']) : null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(isEdit ? "تعديل المنتج" : "إضافة منتج جديد"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Image preview & pick button
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.mainColor.withOpacity(0.3)),
                    color: Colors.grey.shade100,
                    image: selectedImage != null
                        ? DecorationImage(
                      image: FileImage(selectedImage!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: selectedImage == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image_outlined,
                          color: Colors.grey, size: 40),
                      SizedBox(height: 8),
                      Text("اضغط لاختيار صورة",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "اسم المنتج",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: "الوصف",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "السعر",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
            ),
            onPressed: () {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0;

              if (name.isEmpty || price <= 0) return;

              setState(() {
                if (isEdit) {
                  items[index!] = {
                    'name': name,
                    'description': desc,
                    'price': price,
                    'image': selectedImage?.path,
                  };
                } else {
                  items.add({
                    'name': name,
                    'description': desc,
                    'price': price,
                    'image': selectedImage?.path,
                  });
                }
              });

              Navigator.pop(context);
            },
            child: Text(isEdit ? "تحديث" : "إضافة",
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.mainColor),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: items.isEmpty
            ? const Center(
          child: Text("لا توجد منتجات بعد"),
        )
            : ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Card(
                color: Colors.white70,
                elevation: 5,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image preview
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item['image'] != null
                            ? Image.file(
                          File(item['image']),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.fastfood,
                            color: AppColors.mainColor,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Product details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['description'],
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${item['price']} EGP",
                              style: const TextStyle(
                                color: AppColors.mainColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action buttons
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blueAccent),
                            onPressed: () => _showAddOrEditItemDialog(
                              item: item,
                              index: index,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            onPressed: () {
                              setState(() => items.removeAt(index));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.mainColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "إضافة منتج",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddOrEditItemDialog(),
      ),
    );
  }
}
