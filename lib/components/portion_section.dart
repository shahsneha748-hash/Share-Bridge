import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'custom_section.dart';

class PortionSection extends StatelessWidget {
  final int quantity;
  final String unit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Function(String) onUnitChanged;

  const PortionSection({
    super.key,
    required this.quantity,
    required this.unit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: "Portion / Quantity",
      child: Row(
        children: [
          _stepperButton(Icons.remove, onDecrement),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.paleGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$quantity'),
          ),
          _stepperButton(Icons.add, onIncrement),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onUnitChanged,
              decoration: InputDecoration(
                hintText: "Unit (kg, pcs, ...)",
                filled: true,
                fillColor: AppColors.paleGreen,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.paleGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}