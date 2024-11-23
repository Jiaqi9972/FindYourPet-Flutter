import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:flutter/material.dart';

class DividerText extends StatelessWidget {
  final String text;
  final bool isDarkMode;

  const DividerText({
    super.key,
    required this.text,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(
                color: isDarkMode ? AppColorsDark.border : AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text,
            style: TextStyle(
                color: isDarkMode
                    ? AppColorsDark.foreground
                    : AppColors.foreground),
          ),
        ),
        Expanded(
            child: Divider(
                color: isDarkMode ? AppColorsDark.border : AppColors.border)),
      ],
    );
  }
}
