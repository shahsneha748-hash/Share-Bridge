import 'package:flutter/material.dart';
import 'volunteer_verification_screen.dart';

class VolunteerIntroScreen extends StatelessWidget {
  const VolunteerIntroScreen({super.key});

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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const VolunteerVerificationScreen(),
                    ),
                  );
                },
                child: const Text("Continue"),
              )
            ],
          ),
        ),
      ),
    );
  }
}