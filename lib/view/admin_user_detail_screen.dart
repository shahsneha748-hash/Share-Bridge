import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../model/user_admin_model.dart';
import '../viewmodel/user_admin_viewmodel.dart';
import 'package:sharebridge/view/admin_user_detail_screen.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final AppUser user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isBanned = user.status == UserStatus.banned;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('User Details',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: isBanned
                            ? AppColors.dangerBg
                            : AppColors.light1,
                        child: Text(
                          user.initials,
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isBanned
                                  ? AppColors.dangerText
                                  : AppColors.successText),
                        ),
                      ),
                      if (isBanned)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.dangerText,
                              shape: BoxShape.circle,
                              border:
                              Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.block,
                                size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(user.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isBanned
                          ? AppColors.dangerBg
                          : AppColors.successBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isBanned ? 'Banned' : 'Active',
                      style: TextStyle(
                          color: isBanned
                              ? AppColors.dangerText
                              : AppColors.successText,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contact info (fetched live from Firestore)
            _sectionCard(
              title: 'Contact Information',
              icon: Icons.person,
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final data =
                      snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  return Column(
                    children: [
                      _row(Icons.email_outlined, 'Email', user.email),
                      _row(Icons.phone_outlined, 'Phone',
                          data['phone'] ?? 'Not set'),
                      _row(Icons.location_on_outlined, 'Address',
                          data['address'] ?? 'Not set'),
                      _row(Icons.calendar_today_outlined, 'Joined',
                          user.joinDate),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Activity stats
            _sectionCard(
              title: 'Activity',
              icon: Icons.insights,
              child: Column(
                children: [
                  _row(Icons.person_outline, 'Role', user.roleLabel),
                  _row(Icons.card_giftcard_outlined, 'Donations',
                      '${user.totalDonations} items shared'),
                  _row(Icons.inbox_outlined, 'Requests',
                      '${user.totalRequests} requests made'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Ban / Unban button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  isBanned ? Icons.lock_open : Icons.block,
                  color: Colors.white,
                ),
                label: Text(isBanned ? 'Unban User' : 'Ban User',
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isBanned ? AppColors.primary : AppColors.dangerText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _confirmBanToggle(context, isBanned),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _confirmBanToggle(BuildContext context, bool isBanned) {
    final vm = context.read<UserAdminViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(isBanned ? 'Unban User?' : 'Ban User?',
            style: const TextStyle(fontSize: 16)),
        content: Text(isBanned
            ? '${user.name} will be able to use the platform again.'
            : '${user.name} will be restricted from using the platform.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isBanned ? AppColors.primary : AppColors.dangerText,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (isBanned) {
                vm.unbanUser(user.id);
              } else {
                vm.banUser(user.id);
              }
              Navigator.pop(context); // back to list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primary,
                  content: Text(isBanned
                      ? '${user.name} unbanned'
                      : '${user.name} banned'),
                ),
              );
            },
            child: Text(isBanned ? 'Unban' : 'Ban'),
          ),
        ],
      ),
    );
  }
}