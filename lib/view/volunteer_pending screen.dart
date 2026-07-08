import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/view/navigation_screen.dart';
import '../viewmodel/volunteer_view_model.dart';

class VolunteerPendingScreen extends StatelessWidget {
  const VolunteerPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final vm = context.read<VolunteerViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF3A5C2E),
      body: SafeArea(
        child: uid == null
            ? const Center(
          child: Text(
            "Please log in to continue.",
            style: TextStyle(color: Colors.white),
          ),
        )
            : StreamBuilder<String>(
          stream: vm.watchStatus(uid),
          builder: (context, snapshot) {
            final status = snapshot.data ?? "Pending";

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      status == "Approved"
                          ? Icons.check_circle
                          : status == "Rejected"
                          ? Icons.cancel
                          : Icons.hourglass_top,
                      size: 90,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      status == "Approved"
                          ? "Application Approved!"
                          : status == "Rejected"
                          ? "Application Rejected"
                          : "Application Submitted",
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      status == "Approved"
                          ? "You're now a verified volunteer. Welcome aboard!"
                          : status == "Rejected"
                          ? "Your application was not approved.\nYou may reapply from the volunteer page."
                          : "Your volunteer application is under review.\nThis usually takes 1–2 days.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
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
            );
          },
        ),
      ),
    );
  }
}