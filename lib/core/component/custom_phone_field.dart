import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../utils/app_colors/app_colors.dart';

class CustomPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String initialCountryCode;
  final Function(PhoneNumber)? onChanged;
  final FocusNode? focusNode;
  final String hintText;


  const CustomPhoneField({
    super.key,
    required this.controller,
    this.initialCountryCode = "EG",
    this.onChanged,
    this.focusNode,
    this.hintText = 'رقم الهاتف',
  });

  String? _validator(PhoneNumber? number) {
    if (number == null || number.number.isEmpty) {
      return 'من فضلك أدخل رقم الهاتف';
    }

    if (number.number.length != 10) {
      return 'رقم الهاتف يجب أن يكون 10 أرقام';
    }

    if (!number.completeNumber.startsWith("+20")) {
      return 'الرقم يجب أن يبدأ بكود مصر +20';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.ltr,
      child: IntlPhoneField(
        focusNode: focusNode,
        flagsButtonPadding: EdgeInsets.only(left: 8.w),
        countries: const [
          Country(
            name: "Egypt",
            nameTranslations: {"en": "Egypt"},
            flag: "🇪🇬",
            code: "EG",
            dialCode: "20",
            minLength: 10,
            maxLength: 10,
          ),
        ],
        controller: controller,
        initialCountryCode: initialCountryCode,
        validator: _validator,
        showDropdownIcon: false,
        pickerDialogStyle: PickerDialogStyle(backgroundColor: AppColors.white),
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xffE6E9EA), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.mainColor,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
        ),
        invalidNumberMessage: 'رقم هاتف غير صالح!',
        onChanged: onChanged,
      ),
    );
  }
}
