import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sharebridge/model/notification_model.dart';
import 'package:sharebridge/service/notification_service.dart';
import 'package:sharebridge/view/user.dart';
import 'package:sharebridge/viewmodel/notification_view_model.dart';
import '../constants/colors.dart';
import '../model/request_system_model.dart';
import '../utils/chat_helper.dart';
import '../viewmodel/request_system_view_model.dart';
import 'assign_volunteer_screen.dart';
import 'donation_chat_screen.dart';

class RequestSystemScreen extends StatelessWidget {
  const RequestSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: Column(
        children: [
          _TopBar(),
          Expanded(
            child: Consumer<RequestSystemViewModel>(
              builder: (context, vm, _) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  children: [
                    _SearchBar(),
                    const SizedBox(height: 14),
                    _StatsRow(vm: vm),
                    const SizedBox(height: 12),
                    _FilterRow(vm: vm),
                    const SizedBox(height: 12),
                    if (vm.isLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.darkGreen))
                    else if (vm.errorMessage != null)
                      Center(child: Text(vm.errorMessage!, style: const TextStyle(color: AppColors.rejectedText)))
                    else if (vm.filteredRequests.isEmpty)
                        const _EmptyState()
                      else
                        ...vm.filteredRequests.map((r) => _RequestCard(request: r)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top Bar ───────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkGreen,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 14,
        left: 12,
        right: 20,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.darkGreen, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Request',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.read<RequestSystemViewModel>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: TextField(
        onChanged: vm.setSearchQuery,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search requests...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ─── Stats Row ─────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final RequestSystemViewModel vm;
  const _StatsRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          count: vm.acceptedCount,
          label: 'Accepted',
          color: AppColors.darkGreen,
          bgColor: AppColors.paleGreen,
        ),
        const SizedBox(width: 8),
        _StatCard(
          count: vm.rejectedCount,
          label: 'Rejected',
          color: AppColors.rejectedText,
          bgColor: AppColors.rejectedBg,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bgColor;
  const _StatCard({required this.count, required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Row ────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final RequestSystemViewModel vm;
  const _FilterRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: RequestFilter.values.map((f) {
        final isActive = vm.filter == f;
        final label = f.name[0].toUpperCase() + f.name.substring(1);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => vm.setFilter(f),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.darkGreen : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? AppColors.darkGreen : AppColors.border,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive ? AppColors.white : AppColors.darkGreen,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Request Card ──────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final RequestSystemModel request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<RequestSystemViewModel>();
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isDonor = currentUid == request.donorId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(
                        uid: request.userId,
                      ),
                    ),
                  );
                },
                child: _Avatar(
                  name: request.userName,
                  imageUrl: request.userProfilePicture,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.userName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      request.itemName,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Category: ${request.category}",
                      style: const TextStyle(fontSize: 12),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Location: ${request.location}",
                      style: const TextStyle(fontSize: 12),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _formatDate(request.createdAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              if (request.status != 'pending')
                _StatusPill(status: request.status),
            ],
          ),


          const SizedBox(height: 14),

          if (isDonor)
            Row(
              children: [

                // Pending
                if (request.status == 'pending') ...[

                  Expanded(
                    child: _ActionButton(
                      label: 'Accept',
                      icon: Icons.check,
                      color: AppColors.darkGreen,
                      bgColor: AppColors.paleGreen,
                      onTap: () async {
                        final requestVm = context.read<RequestSystemViewModel>();
                        final notificationVm = context.read<NotificationViewModel>();

                        // Update request status
                        await requestVm.updateStatus(request.id, 'accepted');
                        final senderInfo =
                        await notificationVm.getUserById(request.donorId);

                        // Person who created the request
                        final receiverInfo =
                        await notificationVm.getUserById(request.userId);

                        final model = NotificationModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          senderId: request.donorId,
                          senderName: senderInfo.fullName,
                          profilePicture: senderInfo.profilePicture,
                          receiverId: request.userId,
                          receiverName: receiverInfo.fullName,
                          type: NotificationType.request_accepted,
                          body:
                          "${senderInfo.fullName} accepted your request.",
                          createdAt: DateTime.now(),
                          isRead: false,
                          postId: request.id,
                        );

                        final success =
                        await notificationVm.sendNotification(model);

                        if (success) {
                          await NotificationService.display(
                            body: model.body,
                            createdAt: model.createdAt,
                            payload: "request_system_screen",
                            buildContext: context,
                          );

                          Fluttertoast.showToast(
                            msg: "Notification sent successfully",
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Failed to send notification",
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 8),


                  Expanded(
                    child: _ActionButton(
                      label: 'Reject',
                      icon: Icons.close,
                      color: AppColors.rejectedText,
                      bgColor: AppColors.rejectedBg,
                      onTap: () async {
                        final requestVm = context.read<RequestSystemViewModel>();
                        final notificationVm = context.read<NotificationViewModel>();

                        await requestVm.updateStatus(request.id, 'rejected');

                        // Sender = donor (the one who owns the donation)
                        final senderInfo =
                        await notificationVm.getUserById(request.donorId);

                        // Receiver = requester
                        final receiverInfo =
                        await notificationVm.getUserById(request.userId);
                        final model = NotificationModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          senderId: request.donorId,
                          senderName: senderInfo.fullName,
                          profilePicture: senderInfo.profilePicture,
                          receiverId: request.userId,
                          receiverName: receiverInfo.fullName,
                          type: NotificationType.request_rejected,
                          body:
                          "${senderInfo.fullName} rejected your request.",
                          createdAt: DateTime.now(),
                          isRead: false,
                          postId: request.id,
                        );

                        final success =
                        await notificationVm.sendNotification(model);

                        if (success) {
                          await NotificationService.display(
                            body: model.body,
                            createdAt: model.createdAt,
                            payload: "request_system_screen",
                            buildContext: context,
                          );

                          Fluttertoast.showToast(
                            msg: "Notification sent successfully",
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Failed to send notification",
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  _ChatIcon(request: request),
                ],

                // Accepted
                if (request.status == 'accepted') ...[

                  Expanded(
                    child: _ActionButton(
                      label: 'Unaccept',
                      icon: Icons.undo,
                      onTap: () =>
                          vm.updateStatus(request.id, 'pending'),
                      color: AppColors.darkGreen,
                      bgColor: AppColors.paleGreen,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: _ActionButton(
                      label: 'Assign',
                      icon: Icons.person_add,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssignVolunteerScreen(request: request),
                          ),
                        );
                      },
                      color: AppColors.darkGreen,
                      bgColor: AppColors.paleGreen,
                    ),
                  ),

                  const SizedBox(width: 6),

                  _ChatIcon(request: request),

                ],

                // Rejected
                if (request.status == 'rejected')

                  Expanded(
                    child: _ActionButton(
                      label: 'Unreject',
                      icon: Icons.undo,
                      onTap: () =>
                          vm.updateStatus(request.id, 'pending'),
                      color: AppColors.rejectedText,
                      bgColor: AppColors.rejectedBg,
                    ),
                  ),

              ],
            )
          else
          // Requester's own view — just show a chat icon to follow up, no action buttons
            Row(
              children: [
                _ChatIcon(request: request),
              ],
            ),
        ],
      ),
    );
  }


  String _formatDate(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
// ─── Chat Icon ─────────────────────────────────────────────────────────────

class _ChatIcon extends StatelessWidget {

  final RequestSystemModel request;

  const _ChatIcon({required this.request});


  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: () async {

        final chatId = await ChatHelper.openChat(

          otherUserId: request.donorId,

          otherUserName: request.donorName,

          donationId: request.donationId,

          donationTitle: request.itemName,

        );


        if (context.mounted) {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) => DonationChatScreen(

                chatId: chatId,

                otherUserId: request.donorId,

                otherUserName: request.donorName,

                itemName: request.itemName,

              ),

            ),

          );

        }

      },


      child: Container(

        width: 44,

        height: 44,

        decoration: BoxDecoration(

          color: AppColors.darkGreen,

          borderRadius: BorderRadius.circular(10),

        ),


        child: const Icon(

          Icons.chat_bubble_outline,

          color: AppColors.white,

          size: 20,

        ),

      ),

    );

  }
}

// ─── Avatar ────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const _Avatar({
    required this.name,
    this.imageUrl,
  });

  String get initials {
    final parts = name.trim().split(' ');

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24, // was 22
      backgroundColor: AppColors.darkGreen,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
        initials,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      )
          : null,
    );
  }
}

// ─── Status Pill ───────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final configs = {
      'accepted': (bg: AppColors.paleGreen, text: AppColors.darkGreen, border: AppColors.paleGreen),
      'rejected': (bg: AppColors.rejectedBg, text: AppColors.rejectedText, border: AppColors.rejectedBg),
    };
    final c = configs[status] ?? configs['accepted']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.border),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c.text),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color? bgColor;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text('No requests found.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}