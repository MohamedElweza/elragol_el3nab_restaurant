import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';
import '../../../cubit/menu_cubit.dart';
import '../../../cubit/menu_state.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MenuCubit, MenuState>(
      listener: (context, state) {
        if (state is MenuCreatingCategory) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is MenuCategoryCreated) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
        } else if (state is MenuCreateCategoryError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'إضافة قسم جديد',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'اسم القسم *',
                  hintText: 'مثال: المقبلات، الأطباق الرئيسية',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.restaurant_menu),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى إدخال اسم القسم';
                  }
                  if (value.trim().length < 2) {
                    return 'اسم القسم يجب أن يكون أكثر من حرفين';
                  }
                  return null;
                },
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                textDirection: TextDirection.rtl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'وصف القسم',
                  hintText: 'وصف مختصر عن القسم (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: (value) {
                  if (value != null && value.trim().length > 200) {
                    return 'الوصف يجب أن يكون أقل من 200 حرف';
                  }
                  return null;
                },
                maxLength: 200,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      
      context.read<MenuCubit>().createMenuCategory(name, description);
    }
  }
}