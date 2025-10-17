import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors/app_colors.dart';

class AuthSwitchText extends StatelessWidget {
  final String title;
  final String buttonTitle;
  final VoidCallback onPressed;

  AuthSwitchText({
    super.key,
    required this.title,
    required this.buttonTitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,),
        TextButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            minimumSize: WidgetStateProperty.all(Size(0, 0)),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: onPressed,
          child: Text(
            buttonTitle,
            softWrap: true,
            style: TextStyle(
                fontWeight:FontWeight.bold,
                color: AppColors.mainColor),

            ),
          ),

      ],
    );
  }
}
