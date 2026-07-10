import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../model/create_donation_model.dart';

class SuccessScreen extends StatelessWidget {
  final CreateDonationModel donation;

  const SuccessScreen({
    super.key,
    required this.donation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.check_circle,
              color: AppColors.darkGreen,
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              "Donation Posted Successfully",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              donation.itemName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Back to Home",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}