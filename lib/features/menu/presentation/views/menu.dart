import 'package:elragol_el3nab_rest/features/menu/presentation/views/widgets/category_items_screen.dart';
import 'package:flutter/material.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<String> categories = ["السلطات", "المعكرونة", "المشروبات"];
  final TextEditingController _categoryController = TextEditingController();

  void _showAddCategoryDialog() {
    _categoryController.clear();

    if (!mounted) return;
    showDialog(

      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.white,
        title: const Text("إضافة صنف جديد"),
        content: TextField(

          controller: _categoryController,
          decoration: const InputDecoration(
            labelText: "اسم الصنف",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
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
              final name = _categoryController.text.trim();
              if (name.isNotEmpty) {
                setState(() => categories.add(name));
                Navigator.pop(context);
              }
            },
            child: const Text("إضافة", style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "إدارة المنيو",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.mainColor),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "الأصناف",
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: width * 0.04),
            Expanded(
              child: categories.isEmpty
                  ? const Center(
                child: Text("لا توجد أصناف بعد"),
              )
                  : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                    context,
                    categories[index],
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.mainColor,
        icon: const Icon(Icons.add, color: Colors.white,),
        label: const Text("إضافة صنف", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        onPressed: _showAddCategoryDialog,
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, int index) {
    final width = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryItemsScreen(categoryName: title),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.mainColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mainColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: width * 0.025,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.mainColor.withOpacity(0.2),
            child: const Icon(Icons.restaurant_menu, color: AppColors.mainColor),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: const Text(
            "عرض / تعديل المنتجات",
            style: TextStyle(color: Colors.grey),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              setState(() => categories.removeAt(index));
            },
          ),
        ),
      ),
    );
  }
}
