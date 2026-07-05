import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/volunteer_task_model.dart';
import '../constants/colors.dart'; // <-- Change this path if needed
import '../viewmodel/volunteer_task_viewmodel.dart';

class VolunteerHomeScreen extends StatelessWidget {
  const VolunteerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VolunteerTaskViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Volunteer",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Available Deliveries",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),

      body: Container(
        color: AppColors.backgroundGreen,
        child: StreamBuilder<List<VolunteerTaskModel>>(
          stream: vm.availableTasks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            final tasks = snapshot.data ?? [];

            if (tasks.isEmpty) {
              return const Center(
                child: Text(
                  "No available deliveries",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.darkText,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Title
                        Text(
                          task.donationTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.paleGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Available",
                            style: TextStyle(
                              color: AppColors.availableText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.darkGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.pickupLocation,
                                style: const TextStyle(
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              color: AppColors.lightGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.deliveryLocation,
                                style: const TextStyle(
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: AppColors.darkGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.receiverName,
                                style: const TextStyle(
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final uid =
                                  FirebaseAuth.instance.currentUser!.uid;

                              await vm.acceptTask(
                                taskId: task.id,
                                volunteerId: uid,
                              );
                            },
                            child: const Text("Accept Task"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}