import 'package:elragol_el3nab_rest/features/orders/presentation/views/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/component/custom_phone_field.dart';
import '../../../../core/component/custom_text_button.dart';
import '../../../../core/component/custom_text_form_field.dart';
import '../../../../core/utils/app_colors/app_colors.dart';


class SignInViewBody extends StatefulWidget {
  const SignInViewBody({super.key});

  @override
  State<SignInViewBody> createState() => _SignInViewBodyState();
}

class _SignInViewBodyState extends State<SignInViewBody> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController phoneNumberController;
  late TextEditingController passwordController;

  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    phoneNumberController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 60.h),

                /// Header
                Text(
                  'الدخول إلى حسابك',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 25.h),

                /// Phone number field
                CustomPhoneField(
                  focusNode: _phoneFocus,
                  controller: phoneNumberController,
                  onChanged: (phone) {},
                ),

                SizedBox(height: 15.h),

                /// Password field
                CustomTextFormField(
                  prefixIcon: Icon(Icons.password, color: Colors.grey[500]),
                  focusNode: _passwordFocus,
                  title: 'كلمة المرور',
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  isPasswordField: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Go to forget password screen
                    },
                    child: const Text('هل نسيت كلمة المرور؟'),
                  ),
                ),

                SizedBox(height: 8.h),

                /// Sign In button
                CustomTextButton(
                  isLoading: false,
                  title: 'الدخول',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Navigate directly to Orders screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrdersScreen(),
                        ),
                      );
                    }
                  },
                ),


                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
