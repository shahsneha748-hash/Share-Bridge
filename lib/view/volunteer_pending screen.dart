import 'package:flutter/material.dart';
import 'package:sharebridge/view/navigation_screen.dart';

class VolunteerPendingScreen extends StatelessWidget {
  const VolunteerPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A5C2E),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(Icons.hourglass_top,
                  size: 90, color: Colors.white),

              const SizedBox(height: 20),

              const Text(
                "Application Submitted",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Your volunteer application is under review.\n"
                        "This usually takes 1–2 days.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NavigationScreen(),
                    ),
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green,
                ),
                child: const Text("Back to Dashboard"),
              )
            ],
          ),
        ),
      ),
    );
  }
}