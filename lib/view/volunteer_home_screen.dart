import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../model/volunteer_model.dart';
import '../viewmodel/volunteer_task_viewmodel.dart';
import '../viewmodel/volunteer_view_model.dart';

const _brandGreen = Color(0xFF3A5C2E);

class VolunteerHomeScreen extends StatelessWidget {
  const VolunteerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to continue.')),
      );
    }

    final volunteerVm = context.read<VolunteerViewModel>();
    final taskVm = context.watch<VolunteerTaskViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<VolunteerModel>(
          stream: volunteerVm.watchProfile(uid),
          builder: (context, snapshot) {
            final profile = snapshot.data;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _GreetingBar(profile: profile, uid: uid, vm: volunteerVm),
                const SizedBox(height: 20),
                if (taskVm.pendingTasks.isNotEmpty)
                  _AlertCard(
                    icon: Icons.notifications_active,
                    color: Colors.orange,
                    title:
                    '${taskVm.pendingTasks.length} new delivery request${taskVm.pendingTasks.length > 1 ? 's' : ''}',
                    subtitle: 'Waiting for your response',
                  )
                else if (taskVm.activeTasks.isNotEmpty)
                  _AlertCard(
                    icon: Icons.directions_bike,
                    color: _brandGreen,
                    title: 'Delivery in progress',
                    subtitle:
                    '${taskVm.activeTasks.first.pickupAddress} → ${taskVm.activeTasks.first.dropAddress}',
                  )
                else
                  const _EmptyHomeCard(),
                const SizedBox(height: 20),
                if (profile != null) _StatsRow(profile: profile),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GreetingBar extends StatelessWidget {
  final VolunteerModel? profile;
  final String uid;
  final VolunteerViewModel vm;

  const _GreetingBar({required this.profile, required this.uid, required this.vm});

  @override
  Widget build(BuildContext context) {
    final name = (profile?.fullName.isNotEmpty ?? false)
        ? profile!.fullName
        : 'Volunteer';
    final isAccepting = profile?.isAcceptingTasks ?? true;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $name',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                isAccepting ? 'You are accepting tasks' : 'You are paused',
                style: TextStyle(
                  color: isAccepting ? _brandGreen : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isAccepting,
          activeColor: _brandGreen,
          onChanged: (value) => vm.setAcceptingTasks(uid, value),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _AlertCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHomeCard extends StatelessWidget {
  const _EmptyHomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: _brandGreen, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              "You're all caught up. New tasks will show up here.",
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final VolunteerModel profile;
  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Completed',
            value: '${profile.completedTasksCount}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            label: 'Rating',
            value: profile.rating.toStringAsFixed(1),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD4E8C2)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _brandGreen)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}