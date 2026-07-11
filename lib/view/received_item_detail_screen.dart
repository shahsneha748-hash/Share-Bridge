import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/view/review.dart';
import 'package:sharebridge/view/user.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/delivery_tracker_widget.dart';
import '../model/notification_model.dart';
import '../model/volunteer_request_model.dart';
import '../repo/review_repo_impl.dart';
import '../viewmodel/review_view_model.dart';
import '../viewmodel/volunteer_request_viewmodel.dart';
import '../viewmodel/notification_view_model.dart';

const _brandGreen = Color(0xFF3A5C2E);

class ReceivedItemDetailScreen extends StatefulWidget {
  final VolunteerRequestModel item;
  const ReceivedItemDetailScreen({super.key, required this.item});

  @override
  State<ReceivedItemDetailScreen> createState() => _ReceivedItemDetailScreenState();
}

class _ReceivedItemDetailScreenState extends State<ReceivedItemDetailScreen> {
  Map<String, dynamic>? volunteerData;
  bool loadingVolunteer = true;
  String? _lastFetchedVolunteerId;

  Future<void> _fetchVolunteer(String? volunteerId) async {
    if (volunteerId == null || volunteerId.isEmpty) {
      if (mounted) setState(() => loadingVolunteer = false);
      return;
    }
    if (_lastFetchedVolunteerId == volunteerId) return; // already have it
    _lastFetchedVolunteerId = volunteerId;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(volunteerId).get();
      if (!mounted) return;
      setState(() {
        volunteerData = doc.data();
        loadingVolunteer = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingVolunteer = false);
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
        return "Looking for a volunteer to deliver this to you.";
      case 'accepted':
        return "A volunteer has been assigned and is heading to pick it up.";
      case 'inprogress':
        return "Your delivery is on the way to you.";
      case 'reached':
        return "The volunteer has arrived at your location.";
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _brandGreen,
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
          "Delivery Status",
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

          // Fetch volunteer info if it's newly assigned or changed
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
                Text(item.itemName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserProfileScreen(uid: item.donorId)),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("From: ${item.donorName}",
                          style: const TextStyle(color: _brandGreen, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16, color: _brandGreen),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F8F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_statusMessage(item.status),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 20),
                const Text("Volunteer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (!hasVolunteer)
                  const Text("Not assigned yet.", style: TextStyle(color: Colors.grey))
                else if (loadingVolunteer)
                  const Center(child: CircularProgressIndicator())
                else
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name: ${volunteerData?['fullName'] ?? volunteerData?['name'] ?? 'Unknown'}"),
                              Text("Phone: ${volunteerData?['phone'] ?? volunteerData?['phoneNumber'] ?? 'Not available'}"),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
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
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final receiverId = FirebaseAuth.instance.currentUser?.uid;

                        await context.read<VolunteerRequestViewModel>().confirmDelivery(item.requestId);

                        if (receiverId != null) {
                          final notifVm = context.read<NotificationViewModel>();
                          final senderInfo = await notifVm.getUserById(receiverId);

                          // Notify donor
                          await notifVm.sendNotification(
                            NotificationModel(
                              id: '${DateTime.now().millisecondsSinceEpoch}_donor',
                              senderId: receiverId,
                              senderName: senderInfo.fullName,
                              profilePicture: senderInfo.profilePicture,
                              receiverId: item.donorId,
                              type: NotificationType.delivery_confirmed,
                              body: "${senderInfo.fullName} confirmed receiving \"${item.itemName}\".",
                              createdAt: DateTime.now(),
                              isRead: false,
                              postId: item.requestId,
                            ),
                          );

                          // Notify volunteer
                          if (item.assignedVolunteerId != null && item.assignedVolunteerId!.isNotEmpty) {
                            await notifVm.sendNotification(
                              NotificationModel(
                                id: '${DateTime.now().millisecondsSinceEpoch}_volunteer',
                                senderId: receiverId,
                                senderName: senderInfo.fullName,
                                profilePicture: senderInfo.profilePicture,
                                receiverId: item.assignedVolunteerId!,
                                type: NotificationType.delivery_confirmed,
                                body: "${senderInfo.fullName} confirmed delivery of \"${item.itemName}\". Thanks for delivering!",
                                createdAt: DateTime.now(),
                                isRead: false,
                                postId: item.requestId,
                              ),
                            );
                          }
                        }

                        messenger.showSnackBar(
                          const SnackBar(content: Text("Thanks for confirming! Please rate your experience.")),
                        );

                        if (item.assignedVolunteerId != null && item.assignedVolunteerId!.isNotEmpty) {
                          await navigator.push(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider(
                                create: (_) => ReviewViewModel(repository: ReviewRepoImpl()),
                                child: RatingsReviewsPage(
                                  donationId: item.requestId,
                                  targetUserId: item.assignedVolunteerId!,
                                  reviewType: 'volunteer',
                                ),
                              ),
                            ),
                          );
                        }

                        await navigator.push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (_) => ReviewViewModel(repository: ReviewRepoImpl()),
                              child: RatingsReviewsPage(
                                donationId: item.requestId,
                                targetUserId: item.donorId,
                                reviewType: 'donor',
                              ),
                            ),
                          ),
                        );

                        navigator.pop();
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Confirm I Received This"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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