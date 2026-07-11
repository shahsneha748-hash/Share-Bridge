import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/view/volunteer_navigation_screen.dart';
import '../viewmodel/volunteer_view_model.dart';
import 'volunteer_verification_screen.dart';
import 'volunteer_pending screen.dart';

class VolunteerIntroScreen extends StatelessWidget {
  const VolunteerIntroScreen({super.key});

  Future<void> _handleContinue(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final vm = context.read<VolunteerViewModel>();
    final status = await vm.getStatus(user.uid);

    if (!context.mounted) return;

    if (status == "Pending") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VolunteerPendingScreen()),
      );
    } else if (status == "Approved") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VolunteerMainScreen()),
      );
    } else {
      // "none" or "Rejected" -> allow filling/refilling the form
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VolunteerVerificationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A5C2E),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- BACK BUTTON ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF3A5C2E),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ---------------- MAIN CONTENT ----------------
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.volunteer_activism,
                          size: 90, color: Colors.white),
                      const SizedBox(height: 20),
                      const Text(
                        "Become a Volunteer",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Help deliver donations and make impact",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                        ),
                        onPressed: () => _handleContinue(context),
                        child: const Text("Continue"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}