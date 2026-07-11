import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/volunteer_task_model.dart';
import '../viewmodel/volunteer_task_viewmodel.dart';
import 'volunteer_task_detail_screen.dart';

const _brandGreen = Color(0xFF3A5C2E);

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

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
            if (vm.errorMessage != null) {
              return Center(child: Text('Error: ${vm.errorMessage}'));
            }

            final pending = vm.pendingTasks;
            final active = vm.activeTasks;

            if (pending.isEmpty && active.isEmpty) {
              return const _EmptyState();
            }

            String norm(String s) => s.toLowerCase().replaceAll('_', '');
            final inProgress = active.where((t) => norm(t.status) == 'inprogress').toList();
            final accepted = active.where((t) => norm(t.status) == 'accepted').toList();
            final reached = active.where((t) => norm(t.status) == 'reached').toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (pending.isNotEmpty)
                  _Section(
                    title: 'Waiting for your response',
                    icon: Icons.mark_email_unread_outlined,
                    color: Colors.orange,
                    children: pending.map((t) => _PendingTaskCard(task: t)).toList(),
                  ),
                if (inProgress.isNotEmpty)
                  _Section(
                    title: 'On the way',
                    icon: Icons.directions_bike,
                    color: const Color(0xFFD98E3B),
                    children: inProgress.map((t) => _ActiveTaskCard(task: t, accentColor:const Color(0xFFD98E3B))).toList(),
                  ),
                if (accepted.isNotEmpty)
                  _Section(
                    title: 'Accepted',
                    icon: Icons.person_pin_circle_outlined,

                    color: const Color(0xFFC15A3E),
                    children: accepted.map((t) => _ActiveTaskCard(task: t, accentColor: const Color(0xFFC15A3E),)).toList(),
                  ),
                if (reached.isNotEmpty)
                  _Section(
                    title: 'Arrived at destination',
                    icon: Icons.location_on,
                    color: const Color(0xFF5B7A8C),
                    children: reached.map((t) => _ActiveTaskCard(task: t, accentColor: const Color(0xFF5B7A8C))).toList(),
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
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, size: 15, color: Colors.white),
                ),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: color.withOpacity(0.9)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${children.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
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
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No tasks right now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
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

class _PendingTaskCard extends StatelessWidget {
  final VolunteerTaskModel task;
  const _PendingTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<VolunteerTaskViewModel>();
    final isActing = context.watch<VolunteerTaskViewModel>().actingOnTaskId == task.taskId;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.local_shipping_outlined, color: Colors.orange, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('New delivery request',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: isActing
                                  ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                                  : const Text('Accept'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveTaskCard extends StatelessWidget {
  final VolunteerTaskModel task;
  final Color accentColor;
  const _ActiveTaskCard({required this.task, required this.accentColor});

  int _stageIndex(String status) {
    switch (status.toLowerCase().replaceAll('_', '')) {
      case 'accepted':
        return 0;
      case 'inprogress':
        return 1;
      case 'reached':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<VolunteerTaskViewModel>();
    final isActing = context.watch<VolunteerTaskViewModel>().actingOnTaskId == task.taskId;
    final alreadyReached = task.status.toLowerCase() == 'reached';
    final stage = _stageIndex(task.status);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                            child: Icon(alreadyReached ? Icons.flag : Icons.directions_bike,
                                color: accentColor, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              alreadyReached ? 'Reached — waiting for receiver' : 'On the way',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _LocationRow(icon: Icons.circle, label: 'Pickup', address: task.pickupAddress),
                      const SizedBox(height: 6),
                      _LocationRow(icon: Icons.location_on, label: 'Drop', address: task.dropAddress),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stage / 2,
                          minHeight: 5,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        ),
                      ),
                      if (!alreadyReached) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isActing ? null : () => vm.markReached(task.taskId),
                            icon: const Icon(Icons.flag, size: 16),
                            label: isActing
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text('Mark reached destination'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ] else
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Waiting for the receiver to confirm they got the item.',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String address;
  const _LocationRow({required this.icon, required this.label, required this.address});

  @override
  Widget build(BuildContext context) {
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
                TextSpan(text: address),
              ],
            ),
          ),
        ),
      ],
    );
  }
}