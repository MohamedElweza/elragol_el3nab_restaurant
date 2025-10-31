import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';
import '../../../../../core/utils/image_picker_helper.dart';
import '../../../cubit/menu_cubit.dart';
import '../../../cubit/menu_state.dart';

class AddItemDialog extends StatefulWidget {
  final String categoryId;

  const AddItemDialog({
    super.key,
    required this.categoryId,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _prepTimeController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _prepTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MenuCubit, MenuState>(
      listener: (context, state) {
        if (state is MenuCreatingItem) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is MenuItemCreated) {
          // Fallback case - close dialog and show success
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إضافة الصنف بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is MenuItemsLoaded) {
          // Items reloaded after successful creation - close dialog and show success
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إضافة الصنف بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (state is MenuCreateItemError) {
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
          'إضافة صنف جديد',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Field
                TextFormField(
                  controller: _nameController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'اسم الصنف *',
                    hintText: 'مثال: برجر كلاسيك، كباب مشوي',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.fastfood),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال اسم الصنف';
                    }
                    if (value.trim().length < 2) {
                      return 'اسم الصنف يجب أن يكون أكثر من حرفين';
                    }
                    return null;
                  },
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                
                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'وصف الصنف',
                    hintText: 'وصف مختصر عن الصنف ومكوناته',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().length > 300) {
                      return 'الوصف يجب أن يكون أقل من 300 حرف';
                    }
                    return null;
                  },
                  maxLength: 300,
                ),
                const SizedBox(height: 16),
                
                // Price Field
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'السعر (جنيه) *',
                    hintText: '25.50',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                    suffixText: 'جنيه',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال السعر';
                    }
                    final price = double.tryParse(value);
                    if (price == null) {
                      return 'يرجى إدخال سعر صحيح';
                    }
                    if (price <= 0) {
                      return 'السعر يجب أن يكون أكبر من صفر';
                    }
                    if (price > 10000) {
                      return 'السعر يجب أن يكون أقل من 10000 جنيه';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Prep Time Field
                TextFormField(
                  controller: _prepTimeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'وقت التحضير (دقيقة) *',
                    hintText: '15',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.access_time),
                    suffixText: 'دقيقة',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال وقت التحضير';
                    }
                    final prepTime = int.tryParse(value);
                    if (prepTime == null) {
                      return 'يرجى إدخال وقت صحيح';
                    }
                    if (prepTime <= 0) {
                      return 'وقت التحضير يجب أن يكون أكبر من صفر';
                    }
                    if (prepTime > 180) {
                      return 'وقت التحضير يجب أن يكون أقل من 180 دقيقة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Image Picker Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Image Preview
                      Container(
                        height: 150,
                        width: double.infinity,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade100,
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  cacheWidth: 300, // Optimize memory usage
                                  cacheHeight: 150,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      // Image Picker Buttons
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('اختيار صورة'),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedImage != null) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'حذف الصورة',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

  Future<void> _pickImage() async {
    try {
      final image = await ImagePickerHelper.showImagePickerDialog(context);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في اختيار الصورة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitForm() {
    try {
      if (_formKey.currentState!.validate()) {
        final name = _nameController.text.trim();
        final description = _descriptionController.text.trim();
        final price = double.parse(_priceController.text);
        final prepTime = int.parse(_prepTimeController.text);
        
        context.read<MenuCubit>().createMenuItem(
          widget.categoryId,
          name,
          description,
          price,
          prepTime,
          image: _selectedImage,
        );
      }
    } catch (e) {
      print('Error submitting form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في إرسال البيانات'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}