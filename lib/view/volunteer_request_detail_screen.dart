import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../model/notification_model.dart';
import '../model/volunteer_request_model.dart';
import '../viewmodel/notification_view_model.dart';
import '../viewmodel/volunteer_request_viewmodel.dart';

const _brandGreen = Color(0xFF3A5C2E);

class RequestDetailScreen extends StatefulWidget {
  final VolunteerRequestModel request;
  const RequestDetailScreen({super.key, required this.request});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  bool isActing = false;

  Future<void> _handleAccept() async {
    final volunteerId = FirebaseAuth.instance.currentUser?.uid;
    if (volunteerId == null) return;

    setState(() => isActing = true);
    final vm = context.read<VolunteerRequestViewModel>();
    final success = await vm.acceptRequest(widget.request.requestId, volunteerId);
    if (!mounted) return;
    setState(() => isActing = false);

    if (success) {
      final notifVm = context.read<NotificationViewModel>();
      final senderInfo = await notifVm.getUserById(volunteerId);
      await notifVm.sendNotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: volunteerId,
          senderName: senderInfo.fullName,
          profilePicture: senderInfo.profilePicture,
          receiverId: widget.request.donorId,
          receiverName: widget.request.donorName,
          type: NotificationType.volunteer_accepted_delivery,
          body: "${senderInfo.fullName} accepted to deliver \"${widget.request.itemName}\".",
          createdAt: DateTime.now(),
          isRead: false,
          postId: widget.request.requestId,
        ),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "Accepted! Check My Tasks."
            : "Sorry, another volunteer already took this one."),
      ),
    );
    if (success) Navigator.pop(context);
  }

  Future<void> _handleReject() async {
    final volunteerId = FirebaseAuth.instance.currentUser?.uid;
    if (volunteerId == null) return;

    setState(() => isActing = true);
    final vm = context.read<VolunteerRequestViewModel>();
    await vm.rejectRequest(widget.request.requestId, volunteerId);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A5C2E),
        iconTheme: const IconThemeData(
          color: AppColors.cream,
        ),
        title: const Text(
          "Request Details",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.itemName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _section("Donor", [
              _row("Name", r.donorName),
              _row("Phone", r.donorPhone),
            ]),
            _section("Receiver", [
              _row("Name", r.receiverName),
              _row("Phone", r.receiverPhone),
            ]),
            _section("Pickup", [
              _row("Location", r.pickupLocation),
            ]),
            _section("Delivery", [
              _row("Location", r.deliveryLocation),
            ]),
            _section("Item", [
              _row("Weight", r.weight.isEmpty ? "Not specified" : r.weight),
              _row("Quantity", "${r.portionCount} ${r.portion}"),
            ]),
            _section("Logistics", [
              _row("Vehicle needed", r.vehicle ?? "Any"),
              _row("Preferred time", r.preferredTime ?? "Flexible"),
            ]),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isActing ? null : _handleReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Reject"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isActing ? null : _handleAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isActing
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Text("Accept Task"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value.isEmpty ? "Not provided" : value),
          ],
        ),
      ),
    );
  }
}