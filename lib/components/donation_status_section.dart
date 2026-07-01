import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'custom_section.dart';

class DonationStatusSection extends StatelessWidget {
  final bool isDonated;
  final VoidCallback onToggle;

  const DonationStatusSection({
    super.key,
    required this.isDonated,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isDonated ? "Donated" : "Available",
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              const Text(
                "Tap to mark as donated",
                style: TextStyle(fontSize: 12, color: AppColors.subtitleGrey),
              ),
            ],
          ),
          Switch(
            value: isDonated,
            activeThumbColor: AppColors.darkGreen,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}