import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/volunteer_task_model.dart';
import '../viewmodel/volunteer_task_viewmodel.dart';


const _brandGreen = Color(0xFF3A5C2E);

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<VolunteerTaskViewModel>(
          builder: (context, vm, _) {
            if (vm.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.errorMessage != null) {
              return Center(child: Text('Error: ${vm.errorMessage}'));
            }

            final pending = vm.pendingTasks;
            final active = vm.activeTasks;

            if (pending.isEmpty && active.isEmpty) {
              return const _EmptyState();
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (pending.isNotEmpty) ...[
                  const _SectionHeader('Waiting for your response'),
                  ...pending.map((t) => _PendingTaskCard(task: t)),
                  const SizedBox(height: 12),
                ],
                if (active.isNotEmpty) ...[
                  const _SectionHeader('Active'),
                  ...active.map((t) => _ActiveTaskCard(task: t)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.assignment_turned_in_outlined,
                size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tasks right now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'When a donor assigns you a delivery, it will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _PendingTaskCard extends StatelessWidget {
  final VolunteerTaskModel task;
  const _PendingTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<VolunteerTaskViewModel>();
    final isActing = context.watch<VolunteerTaskViewModel>().actingOnTaskId ==
        task.taskId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFD4E8C2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_shipping_outlined, color: _brandGreen),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('New delivery request',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _LocationRow(icon: Icons.circle, label: 'Pickup', address: task.pickupAddress),
            const SizedBox(height: 6),
            _LocationRow(icon: Icons.location_on, label: 'Drop', address: task.dropAddress),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isActing ? null : () => vm.reject(task.taskId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isActing ? null : () => vm.accept(task.taskId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: isActing
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final VolunteerTaskModel task;
  const _ActiveTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<VolunteerTaskViewModel>();
    final isActing = context.watch<VolunteerTaskViewModel>().actingOnTaskId ==
        task.taskId;
    final alreadyReached = task.status == 'Reached';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFFF6F8F1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  alreadyReached ? Icons.flag : Icons.directions_bike,
                  color: _brandGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  alreadyReached ? 'Reached - waiting for receiver' : 'On the way',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _LocationRow(icon: Icons.circle, label: 'Pickup', address: task.pickupAddress),
            const SizedBox(height: 6),
            _LocationRow(icon: Icons.location_on, label: 'Drop', address: task.dropAddress),
            if (!alreadyReached) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isActing ? null : () => vm.markReached(task.taskId),
                  icon: const Icon(Icons.flag),
                  label: isActing
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Mark reached destination'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Waiting for the receiver to confirm they got the item.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String address;

  const _LocationRow({
    required this.icon,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: address),
              ],
            ),
          ),
        ),
      ],
    );
  }
}