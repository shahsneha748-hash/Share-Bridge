import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/volunteer_task_model.dart';
import '../viewmodel/volunteer_task_viewmodel.dart';

class TaskDetailScreen extends StatelessWidget {
  final VolunteerTaskModel task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<VolunteerTaskViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mission Details"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (task.donationImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  task.donationImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 16),

            Text(
              task.donationTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _infoRow("Pickup Location", task.pickupLocation),
            _infoRow("Delivery Location", task.deliveryLocation),
            _infoRow("Receiver", task.receiverName),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Status: In Progress",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await viewModel.completeTask(task.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mission Completed 🎉"),
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text("Complete Delivery"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}