import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/delivery_tracker_widget.dart';
import '../model/volunteer_request_model.dart';
import 'item_detail_screen.dart';
import 'user.dart';

const _brandGreen = Color(0xFF3A5C2E);

class DonatedItemDetailScreen extends StatefulWidget {
  final VolunteerRequestModel item;
  const DonatedItemDetailScreen({super.key, required this.item});

  @override
  State<DonatedItemDetailScreen> createState() => _DonatedItemDetailScreenState();
}

class _DonatedItemDetailScreenState extends State<DonatedItemDetailScreen> {
  Map<String, dynamic>? volunteerData;
  bool loadingVolunteer = true;
  String? _lastFetchedVolunteerId;
  int _completedDeliveries = 0;

  Future<void> _fetchVolunteer(String? volunteerId) async {
    if (volunteerId == null || volunteerId.isEmpty) {
      if (mounted) setState(() => loadingVolunteer = false);
      return;
    }
    if (_lastFetchedVolunteerId == volunteerId) return;
    _lastFetchedVolunteerId = volunteerId;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(volunteerId).get();
      final volunteerDoc = await FirebaseFirestore.instance.collection('volunteers').doc(volunteerId).get();
      if (!mounted) return;
      setState(() {
        volunteerData = userDoc.data();
        _completedDeliveries = (volunteerDoc.data()?['completedTasksCount'] as num?)?.toInt() ?? 0;
        loadingVolunteer = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingVolunteer = false);
    }
  }

  Future<void> _openOriginalDonation(BuildContext context, String donationId) async {
    if (donationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Original donation post not found")),
      );
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('donations').doc(donationId).get();
      if (!context.mounted) return;
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Original donation post no longer exists")),
        );
        return;
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetailScreen(item: data)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't load donation post: $e")),
      );
    }
  }

  Future<void> _openInMaps(double lat, double lng) async {
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _statusMessage(String status) {
    switch (status.toLowerCase().replaceAll('_', '')) {
      case 'pending':
        return "Looking for a volunteer to deliver this.";
      case 'accepted':
        return "A volunteer has accepted and will pick this up soon.";
      case 'inprogress':
        return "Your donation is on the way to the receiver.";
      case 'reached':
        return "The volunteer has arrived at the delivery location.";
      case 'delivered':
      case 'completed':
        return "Delivered.";
      default:
        return status;
    }
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
        title: const Text(
          "Donation Status",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('volunteer_requests')
            .doc(widget.item.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: _brandGreen));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("This request no longer exists."));
          }

          final item = VolunteerRequestModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
            snapshot.data!.id,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchVolunteer(item.assignedVolunteerId);
          });

          final hasVolunteer = item.assignedVolunteerId != null && item.assignedVolunteerId!.isNotEmpty;
          final loc = item.currentLocation;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item header card (tap to view original donation post)
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openOriginalDonation(context, item.donationId),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _brandGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: _brandGreen),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.itemName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text("To: ${item.receiverName}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 6),
                              Text(_statusMessage(item.status),
                                  style: const TextStyle(
                                      color: _brandGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Volunteer card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.person_outline, size: 18, color: _brandGreen),
                          SizedBox(width: 8),
                          Text("Volunteer", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (!hasVolunteer)
                        const Text("Not assigned yet.", style: TextStyle(color: Colors.grey, fontSize: 13))
                      else if (loadingVolunteer)
                        const Center(child: CircularProgressIndicator(color: _brandGreen))
                      else
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfileScreen(uid: item.assignedVolunteerId!),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: _brandGreen.withOpacity(0.1),
                                child: Text(
                                  (volunteerData?['fullName'] ?? volunteerData?['name'] ?? '?')
                                      .toString()
                                      .trim()
                                      .isNotEmpty
                                      ? (volunteerData?['fullName'] ?? volunteerData?['name'])
                                      .toString()
                                      .trim()[0]
                                      .toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: _brandGreen, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          volunteerData?['fullName'] ?? volunteerData?['name'] ?? 'Unknown',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        if (_completedDeliveries >= 500) ...[
                                          const SizedBox(width: 6),
                                          Icon(Icons.auto_awesome, size: 14, color: Colors.amber.shade700),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      volunteerData?['phone'] ?? volunteerData?['phoneNumber'] ?? 'Not available',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Live tracking widget
                DeliveryTrackerWidget(
                  status: item.status,
                  locationUpdatedAt: item.locationUpdatedAt,
                  pickupAddress: item.pickupLocation,
                  deliveryAddress: item.deliveryLocation,
                  currentLat: loc != null ? (loc['lat'] as num).toDouble() : null,
                  currentLng: loc != null ? (loc['lng'] as num).toDouble() : null,
                ),
                if (loc != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openInMaps(
                        (loc['lat'] as num).toDouble(),
                        (loc['lng'] as num).toDouble(),
                      ),
                      icon: const Icon(Icons.directions_outlined, size: 18),
                      label: const Text("Get Directions"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _brandGreen,
                        side: const BorderSide(color: _brandGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}