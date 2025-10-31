import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/component/custom_text_form_field.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';

class EditProfileInfoViewBody extends StatefulWidget {
  const EditProfileInfoViewBody({super.key});

  @override
  State<EditProfileInfoViewBody> createState() => _EditProfileInfoViewBodyState();
}

class _EditProfileInfoViewBodyState extends State<EditProfileInfoViewBody> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController(text: 'مطعم الرجل العنّاب');
  final TextEditingController _descController = TextEditingController(
      text: 'مطعم متخصص في الأكلات الصحية والوجبات المتوازنة.');
  final TextEditingController _typeController =
  TextEditingController(text: 'صحي / نباتي');
  final TextEditingController _openHourController =
  TextEditingController(text: '08:00 ص');
  final TextEditingController _closeHourController =
  TextEditingController(text: '12:00 ص');
  final TextEditingController _daysController =
  TextEditingController(text: 'من السبت إلى الخميس');

  @override
  Widget build(BuildContext context) {
    return Directionality( // ensure proper Arabic layout
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: AppColors.mainColor.withOpacity(0.1),
                      child: const Icon(Icons.store, color: AppColors.mainColor),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'بيانات المطعم',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),

                // Restaurant Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55.r,
                        backgroundImage:
                        const AssetImage('assets/images/restaurant.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18.r,
                          backgroundColor: AppColors.mainColor,
                          child: IconButton(
                            iconSize: 18.sp,
                            onPressed: () {},
                            icon: const Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Restaurant name
                CustomTextFormField(
                  title: 'اسم المطعم',
                  controller: _nameController,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'الرجاء إدخال اسم المطعم' : null,
                  prefixIcon:
                  Icon(Icons.storefront_rounded, color: Colors.grey[500]),
                ),
                SizedBox(height: 14.h),

                // Description
                CustomTextFormField(
                  title: 'الوصف',
                  controller: _descController,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'الرجاء إدخال الوصف' : null,
                  keyboardType: TextInputType.multiline,
                  prefixIcon: Icon(Icons.description, color: Colors.grey[500]),
                ),
                SizedBox(height: 14.h),

                // Type
                CustomTextFormField(
                  title: 'نوع المطعم',
                  controller: _typeController,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'الرجاء تحديد نوع المطعم' : null,
                  prefixIcon:
                  Icon(Icons.category_outlined, color: Colors.grey[500]),
                ),
                SizedBox(height: 14.h),

                // Open Hour
                CustomTextFormField(
                  title: 'ساعة الفتح',
                  controller: _openHourController,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'أدخل ساعة الفتح' : null,
                  prefixIcon: Icon(Icons.access_time, color: Colors.grey[500]),
                ),
                SizedBox(height: 14.h),

                // Close Hour
                CustomTextFormField(
                  title: 'ساعة الإغلاق',
                  controller: _closeHourController,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'أدخل ساعة الإغلاق' : null,
                  prefixIcon:
                  Icon(Icons.access_time_filled, color: Colors.grey[500]),
                ),
                SizedBox(height: 14.h),

                // Working days
                CustomTextFormField(
                  title: 'أيام العمل',
                  controller: _daysController,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'أدخل أيام العمل' : null,
                  prefixIcon:
                  Icon(Icons.calendar_month, color: Colors.grey[500]),
                ),
                SizedBox(height: 28.h),

                // Update button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم تحديث بيانات المطعم بنجاح ✅'),
                            backgroundColor: AppColors.mainColor,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Text("تحديث البيانات"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
