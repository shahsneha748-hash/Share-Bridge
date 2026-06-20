import 'package:flutter/material.dart';
import 'package:sharebridge/constants/colors.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final Widget? trailing; // optional — pass bell, back button, etc.

  const AppHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      color: AppColors.darkGreen,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}