import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/volunteer_request_model.dart';
import '../viewmodel/received_items_viewmodel.dart';
import 'received_item_detail_screen.dart';

const _brandGreen = Color(0xFF3A5C2E);

class ReceivedItemsScreen extends StatefulWidget {
  const ReceivedItemsScreen({super.key});

  @override
  State<ReceivedItemsScreen> createState() => _ReceivedItemsScreenState();
}

class _ReceivedItemsScreenState extends State<ReceivedItemsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<ReceivedItemsViewModel>().listenFor(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        backgroundColor: _brandGreen,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFFF5F0E8),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFF5F0E8),
            size: 20,
          ),
        ),
        title: const Text(
          "Items Received",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ReceivedItemsViewModel>(
        builder: (context, vm, _) {
          if (vm.loading && vm.items.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: _brandGreen));
          }
          if (vm.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text("No items received yet.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          String norm(String s) => s.toLowerCase().replaceAll('_', '');

          final pending = vm.items.where((i) => norm(i.status) == 'pending').toList();
          final inProgress = vm.items.where((i) => norm(i.status) == 'inprogress').toList();
          final accepted = vm.items.where((i) => norm(i.status) == 'accepted').toList();
          final reached = vm.items.where((i) => norm(i.status) == 'reached').toList();
          final completed = vm.items
              .where((i) => norm(i.status) == 'completed' || norm(i.status) == 'delivered')
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              if (pending.isNotEmpty)
                _Section(
                  title: 'Looking for a volunteer',
                  icon: Icons.hourglass_empty,
                  color: const Color(0xFFD98E3B),
                  items: pending,
                ),
              if (inProgress.isNotEmpty)
                _Section(
                  title: 'On the way',
                  icon: Icons.directions_bike,
                  color: const Color(0xFFC15A3E),
                  items: inProgress,
                ),
              if (accepted.isNotEmpty)
                _Section(
                  title: 'Volunteer assigned',
                  icon: Icons.person_pin_circle_outlined,
                  color: const Color(0xFF5B7A8C),
                  items: accepted,
                ),
              if (reached.isNotEmpty)
                _Section(
                  title: 'Arrived — ready to confirm',
                  icon: Icons.location_on,
                  color: const Color(0xFF3B7A78),
                  items: reached,
                ),
              if (completed.isNotEmpty)
                _Section(
                  title: 'Completed',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  items: completed,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<VolunteerRequestModel> items;

  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
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
                child: Text('${items.length}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => _ReceivedCard(item: item, accentColor: color)),
        ],
      ),
    );
  }
}

/// Stage index used to render the mini progress stepper on each card.
int _stageIndex(String status) {
  switch (status.toLowerCase().replaceAll('_', '')) {
    case 'pending':
      return 0;
    case 'accepted':
      return 1;
    case 'inprogress':
      return 2;
    case 'reached':
      return 3;
    case 'completed':
    case 'delivered':
      return 4;
    default:
      return 0;
  }
}

class _ReceivedCard extends StatelessWidget {
  final VolunteerRequestModel item;
  final Color accentColor;
  const _ReceivedCard({required this.item, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final stage = _stageIndex(item.status);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReceivedItemDetailScreen(item: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.card_giftcard_outlined, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.itemName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text("From: ${item.donorName}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
            const SizedBox(height: 14),
            _MiniStepper(stage: stage),
          ],
        ),
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  final int stage; // 0..4
  const _MiniStepper({required this.stage});

  static const _labels = ['Requested', 'Assigned', 'On the way', 'Arrived', 'Delivered'];

  @override
  Widget build(BuildContext context) {
    final progress = stage / (_labels.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(_brandGreen),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _labels[stage],
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _brandGreen),
        ),
      ],
    );
  }
}