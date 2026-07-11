import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/volunteer_request_model.dart';
import '../viewmodel/donated_items_viewmodel.dart';
import 'donated_item_detail_screen.dart';

const _brandGreen = Color(0xFF3A5C2E);

class DonatedItemsScreen extends StatelessWidget {
  const DonatedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      appBar: AppBar(
        backgroundColor: _brandGreen,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFFF5F0E8), // cream
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
          "Delivery Tracking",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<DonatedItemsViewModel>(
        builder: (context, vm, _) {
          if (vm.loading && vm.items.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: _brandGreen));
          }
          if (vm.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text("No items assigned to a volunteer yet.",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          String norm(String s) => s.toLowerCase().replaceAll('_', '');

          final pending = vm.items.where((i) => norm(i.status) == 'pending').toList();
          final accepted = vm.items.where((i) => norm(i.status) == 'accepted').toList();
          final inProgress = vm.items.where((i) => norm(i.status) == 'inprogress').toList();
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
                  color: Colors.orange,
                  items: pending,
                ),
              if (inProgress.isNotEmpty)
                _Section(
                  title: 'On the way',
                  icon: Icons.directions_bike,
                  color: Colors.deepPurple,
                  items: inProgress,
                ),
              if (accepted.isNotEmpty)
                _Section(
                  title: 'Volunteer assigned',
                  icon: Icons.person_pin_circle_outlined,
                  color: Colors.blue,
                  items: accepted,
                ),
              if (reached.isNotEmpty)
                _Section(
                  title: 'Arrived at destination',
                  icon: Icons.location_on,
                  color: Colors.teal,
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
          ...items.map((item) => _DonatedCard(item: item, accentColor: color)),
        ],
      ),
    );
  }
}

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

class _DonatedCard extends StatelessWidget {
  final VolunteerRequestModel item;
  final Color accentColor;
  const _DonatedCard({required this.item, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final stage = _stageIndex(item.status);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DonatedItemDetailScreen(item: item)),
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
                  child: Icon(Icons.inventory_2_outlined, color: accentColor, size: 20),
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
                      Text("To: ${item.receiverName}",
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