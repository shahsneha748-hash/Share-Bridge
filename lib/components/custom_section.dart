import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomSection extends StatelessWidget {
  final String? title;
  final Widget? titleTrailing;
  final Widget child;

  const CustomSection({
    super.key,
    this.title,
    this.titleTrailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title!, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (titleTrailing != null) titleTrailing!,
              ],
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}