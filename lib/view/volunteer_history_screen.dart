import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/volunteer_task_model.dart';
import '../viewmodel/volunteer_task_viewmodel.dart';

const _brandGreen = Color(0xFF3A5C2E);

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(
        child: Consumer<VolunteerTaskViewModel>(
          builder: (context, vm, _) {
            if (vm.loading) {
              return const Center(child: CircularProgressIndicator(color: _brandGreen));
            }

            final historyTasks = vm.pastTasks;
            if (historyTasks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        "No delivery history",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Completed and rejected tasks will appear here.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            final completed = historyTasks.where((t) => t.status.toLowerCase() == "completed").toList();
            final rejected = historyTasks.where((t) => t.status.toLowerCase() == "rejected").toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (completed.isNotEmpty)
                  _Section(
                    title: 'Completed deliveries',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    tasks: completed,
                  ),
                if (rejected.isNotEmpty)
                  _Section(
                    title: 'Rejected requests',
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                    tasks: rejected,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<VolunteerTaskModel> tasks;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${tasks.length}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tasks.map((t) => _HistoryCard(task: t, accentColor: color)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final VolunteerTaskModel task;
  final Color accentColor;
  const _HistoryCard({required this.task, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final completed = task.status.toLowerCase() == "completed";
    String dateLabel = '';
    if (task.respondedAt != null) {
      final d = task.respondedAt!;
      dateLabel = '${d.day}/${d.month}/${d.year}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  completed ? Icons.check_circle : Icons.cancel,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.itemName.isEmpty ? "Donation item" : task.itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (dateLabel.isNotEmpty)
                Text(dateLabel, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          _detailRow(Icons.circle, "Pickup", task.pickupAddress),
          const SizedBox(height: 6),
          _detailRow(Icons.location_on, "Drop", task.dropAddress),
          const SizedBox(height: 6),
          _detailRow(Icons.person_outline, "Receiver",
              task.receiverName.isEmpty ? "Unknown" : task.receiverName),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 12.5),
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}