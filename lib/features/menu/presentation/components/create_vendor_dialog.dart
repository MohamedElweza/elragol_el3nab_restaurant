import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';
import '../../../../../core/utils/image_picker_helper.dart';
import '../../data/models/vendor_category.dart';
import '../../data/repos/menu_repository.dart';

class CreateVendorDialog extends StatefulWidget {
  final Function(String name, String description, String categoryId, String openHour, String closeHour, List<String> days, {File? image}) onCreateVendor;
  final MenuRepository menuRepository;

  const CreateVendorDialog({
    super.key,
    required this.onCreateVendor,
    required this.menuRepository,
  });

  @override
  State<CreateVendorDialog> createState() => _CreateVendorDialogState();
}

class _CreateVendorDialogState extends State<CreateVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _openHourController = TextEditingController();
  final _closeHourController = TextEditingController();
  
  final List<String> _availableDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  final List<String> _availableDaysArabic = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
  ];
  final List<String> _selectedDays = [];
  
  List<VendorCategory> _vendorCategories = [];
  VendorCategory? _selectedCategory;
  bool _isLoadingCategories = true;
  bool _hasLoadedCategories = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load categories only once when dependencies are available
    if (!_hasLoadedCategories) {
      _hasLoadedCategories = true;
      _loadVendorCategories();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _openHourController.dispose();
    _closeHourController.dispose();
    super.dispose();
  }

  Future<void> _loadVendorCategories() async {
    try {
      final categories = await widget.menuRepository.getVendorCategories();
      if (mounted) {
        setState(() {
          _vendorCategories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      log('❌ CreateVendorDialog: Error loading vendor categories: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
        // Use post-frame callback to ensure the widget tree is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل في تحميل أنواع المطاعم: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار نوع المطعم'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار أيام العمل'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!_isValidTimeFormat(_openHourController.text.trim()) ||
          !_isValidTimeFormat(_closeHourController.text.trim())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('صيغة الوقت يجب أن تكون HH:MM (مثال: 09:00)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      log('🍽️ CreateVendorDialog: Creating vendor with name: ${_nameController.text}');
      
      widget.onCreateVendor(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        _selectedCategory!.id,
        _openHourController.text.trim(),
        _closeHourController.text.trim(),
        _selectedDays,
        image: _selectedImage,
      );
      
      Navigator.of(context).pop();
    }
  }

  bool _isValidTimeFormat(String time) {
    return RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time);
  }

  Future<void> _pickImage() async {
    final image = await ImagePickerHelper.showImagePickerDialog(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: AppColors.mainColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.mainColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.store_outlined,
            color: AppColors.mainColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'إنشاء ملف المطعم',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.mainColor,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.mainColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.mainColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'يجب إنشاء ملف المطعم أولاً للتمكن من إدارة القوائم والأصناف',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Restaurant Name
                _buildTextField(
                  controller: _nameController,
                  hintText: 'اسم المطعم',
                  icon: Icons.restaurant_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال اسم المطعم';
                    }
                    if (value.trim().length < 2) {
                      return 'يجب أن يكون اسم المطعم مكون من حرفين على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Description
                _buildTextField(
                  controller: _descriptionController,
                  hintText: 'وصف المطعم',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال وصف المطعم';
                    }
                    if (value.trim().length < 10) {
                      return 'يجب أن يكون الوصف مكون من 10 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Category Selection
                _isLoadingCategories
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : DropdownButtonFormField<VendorCategory>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          hintText: 'اختر نوع المطعم',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: Colors.grey[700],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.mainColor),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: _vendorCategories.map((category) {
                          return DropdownMenuItem<VendorCategory>(
                            value: category,
                            child: Text(
                              category.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (VendorCategory? value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'يرجى اختيار نوع المطعم';
                          }
                          return null;
                        },
                      ),
                const SizedBox(height: 12),

                // Working Hours
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _openHourController,
                        hintText: 'ساعة الفتح (09:00)',
                        icon: Icons.access_time,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال ساعة الفتح';
                          }
                          if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value.trim())) {
                            return 'صيغة خاطئة (HH:MM)';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _closeHourController,
                        hintText: 'ساعة الإغلاق (21:00)',
                        icon: Icons.access_time_filled,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال ساعة الإغلاق';
                          }
                          if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value.trim())) {
                            return 'صيغة خاطئة (HH:MM)';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Working Days
                const Text(
                  'أيام العمل:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: List.generate(_availableDays.length, (index) {
                    final day = _availableDays[index];
                    final dayArabic = _availableDaysArabic[index];
                    final isSelected = _selectedDays.contains(day);
                    
                    return FilterChip(
                      label: Text(dayArabic),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                      selectedColor: AppColors.mainColor.withOpacity(0.3),
                      checkmarkColor: AppColors.mainColor,
                    );
                  }),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'شعار المطعم:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                      ),
                      // Image Preview
                      Container(
                        height: 150,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
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
                                ),
                              )
                            : ImagePickerHelper.buildImageWidget(
                                imagePath: null,
                                placeholderType: 'vendor',
                                width: double.infinity,
                                height: 150,
                                borderRadius: BorderRadius.circular(8),
                              ),
                      ),
                      // Image Picker Buttons
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('اختيار شعار'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.mainColor,
                                  side: BorderSide(color: AppColors.mainColor),
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
                                tooltip: 'حذف الشعار',
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'إلغاء',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _handleCreate,
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text(
            'إنشاء المطعم',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}