import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/view/volunteer_request_detail_screen.dart';
import '../components/break_toggle_bar.dart';
import '../model/volunteer_request_model.dart';
import '../model/volunteer_model.dart';
import '../repo/volunteer_repo.dart';
import '../viewmodel/volunteer_request_viewmodel.dart';


class VolunteerHomeScreen extends StatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  State<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends State<VolunteerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A5C2E),
        iconTheme: const IconThemeData(
          color: Color(0xFFF5F0E8),
        ),
        title: const Text(
          "Available Requests",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (uid != null) BreakToggleChip(uid: uid),
        ],
      ),
      body: uid == null
          ? const SizedBox.shrink()
          : StreamBuilder<VolunteerModel>(
        stream: context.read<VolunteerRepo>().watchProfile(uid),
        builder: (context, profileSnapshot) {
          final isAccepting = profileSnapshot.data?.isAcceptingTasks ?? true;
          final vm = context.read<VolunteerRequestViewModel>();

          // React to break status changes: stop/start the live stream.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isAccepting) {
              vm.listenRequests(volunteerId: uid);
            } else {
              vm.stopListening();
            }
          });

          return Consumer<VolunteerRequestViewModel>(
            builder: (context, vm, _) {
              if (vm.requests.isEmpty) {
                return const Center(
                  child: Text(
                    "No pending requests right now.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              final list = ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: vm.requests.length,
                itemBuilder: (context, index) {
                  final request = vm.requests[index];
                  return _RequestCard(request: request);
                },
              );

              if (!isAccepting) {
                return Stack(
                  children: [
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: AbsorbPointer(child: list),
                    ),
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.15),
                        alignment: Alignment.center,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.pause_circle_outline, size: 40, color: Color(0xFF3A5C2E)),
                              const SizedBox(height: 10),
                              const Text(
                                "You're on a break",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "New requests are paused. Go back online to resume.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<VolunteerRepo>().setAcceptingTasks(uid, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A5C2E),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text("Go Online"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return list;
            },
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final VolunteerRequestModel request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestDetailScreen(request: request),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8F1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.itemName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("From: ${request.donorName}"),
            Text("To: ${request.receiverName}"),
            const SizedBox(height: 4),
            Text("Pickup: ${request.pickupLocation}",
                style: const TextStyle(color: Colors.grey)),
            Text("Deliver to: ${request.deliveryLocation}",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Tap for details →",
                style: TextStyle(color: Color(0xFF3A5C2E), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}