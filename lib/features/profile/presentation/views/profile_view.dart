import 'package:flutter/material.dart';
import '../../../../../core/utils/app_colors/app_colors.dart';
import 'edit_profile_info_view.dart';

class ProfileView extends StatelessWidget {
  static const routeName = "profileView";

  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: const SafeArea(child: EditProfileInfoViewBody()),
    );
  }
}
