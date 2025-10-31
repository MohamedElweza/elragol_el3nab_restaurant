import 'package:elragol_el3nab_rest/features/orders/presentation/views/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/component/custom_phone_field.dart';
import '../../../../core/component/custom_text_button.dart';
import '../../../../core/component/custom_text_form_field.dart';
import '../../../../core/utils/app_colors/app_colors.dart';
import '../../../../core/utils/helpers/phone_helper.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_states.dart';


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
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSignInSuccess) {
            // Navigate to Orders screen on successful login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OrdersScreen(),
              ),
            );
          } else if (state is AuthError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          return Form(
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
                      isLoading: isLoading,
                      title: 'الدخول',
                      onPressed: isLoading ? null : () {
                        if (formKey.currentState!.validate()) {
                          final phoneText = phoneNumberController.text;
                          final phoneNumber = PhoneHelper.extractPhoneNumber(phoneText);
                          final isValid = PhoneHelper.isValidEgyptianPhone(phoneText);
                          
                          // Debug info
                          print('Phone text: $phoneText');
                          print('Extracted number: $phoneNumber');
                          print('Is valid: $isValid');
                          
                          if (phoneNumber != null && isValid) {
                            context.read<AuthCubit>().signIn(
                              phone: phoneNumber,
                              password: passwordController.text,
                            );
                          } else {
                            String errorMessage = 'الرجاء إدخال رقم هاتف مصري صحيح';
                            if (phoneNumber == null) {
                              errorMessage = 'الرجاء إدخال رقم هاتف';
                            } else if (phoneNumber.toString().length != 10) {
                              errorMessage = 'رقم الهاتف يجب أن يكون 10 أرقام';
                            } else if (!phoneNumber.toString().startsWith('1')) {
                              errorMessage = 'رقم الهاتف يجب أن يبدأ بـ 1';
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
