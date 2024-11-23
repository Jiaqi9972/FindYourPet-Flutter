import 'package:flutter/cupertino.dart';
import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final List<Widget>? actions;
  final Widget? media;
  final Widget? content;
  final Widget? footer;
  final bool isDarkMode;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.actions,
    this.media,
    this.content,
    this.footer,
    this.isDarkMode = false,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.background : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? AppColorsDark.border : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null ||
                title != null ||
                subtitle != null ||
                actions != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null) title!,
                        if (subtitle != null) ...[
                          SizedBox(height: 4),
                          subtitle!,
                        ],
                      ],
                    ),
                  ),
                  if (actions != null) ...[
                    SizedBox(width: 8),
                    ...actions!,
                  ],
                ],
              ),
            if (media != null) ...[
              SizedBox(height: 12),
              media!,
            ],
            if (content != null) ...[
              SizedBox(height: 12),
              content!,
            ],
            if (footer != null) ...[
              SizedBox(height: 12),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
