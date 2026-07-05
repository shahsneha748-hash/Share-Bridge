import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_admin_viewmodel.dart';
import '../model/user_admin_model.dart';
import 'admin_dashboard_view.dart';
import '../constants/colors.dart';

class UsersAdminScreen extends StatelessWidget {
  const UsersAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserAdminViewModel()..loadUsers(),
      child: const _UsersBody(),
    );
  }
}

class _UsersBody extends StatelessWidget {
  const _UsersBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UserAdminViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(context, controller),
          _buildSummaryRow(controller),
          _buildSearchBar(context, controller),
          _buildFilterRow(controller),
          Expanded(
            child: controller.isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary))
                : controller.filteredUsers.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding:
              const EdgeInsets.fromLTRB(14, 12, 14, 24),
              itemCount: controller.filteredUsers.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (_, i) => _UserCard(
                user: controller.filteredUsers[i],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TOP BAR ────────────────────────────────────────────────────────────────

  Widget _buildTopBar(
      BuildContext context, UserAdminViewModel controller) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 4, right: 16, bottom: 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left,
                color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text('Users',
                style: TextStyle(color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${controller.totalUsers} total',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ── SUMMARY ROW ────────────────────────────────────────────────────────────

  Widget _buildSummaryRow(UserAdminViewModel controller) {
    final stats = {
      'Total':  controller.totalUsers,
      'Active': controller.activeUsers,
      'Donors': controller.donorCount,
      'Banned': controller.bannedUsers,
    };
    final colors = {
      'Total':  AppColors.primary,
      'Active': AppColors.successText,
      'Donors': AppColors.blueText,
      'Banned': AppColors.dangerText,
    };

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Row(
        children: stats.entries.map((e) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(e.value.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors[e.key],
                      )),
                  const SizedBox(height: 2),
                  Text(e.key,
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── SEARCH BAR ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar(
      BuildContext context, UserAdminViewModel controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: TextField(
        onChanged: controller.search,
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: const TextStyle(
              fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search,
              color: AppColors.textMuted, size: 20),
          filled: true,
          fillColor: AppColors.background,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── FILTER ROW ─────────────────────────────────────────────────────────────

  Widget _buildFilterRow(UserAdminViewModel controller) {
    final roleFilters = <String, UserRole?>{
      'All':        null,
      'Donors':     UserRole.donor,
      'Receivers':  UserRole.receiver,
      'Volunteers': UserRole.volunteer,
    };

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            _FilterChip(
              label: 'Banned',
              isActive:
              controller.filterStatus == UserStatus.banned,
              activeColor: AppColors.dangerText,
              activeBg: AppColors.dangerBg,
              onTap: () => controller.setStatusFilter(
                controller.filterStatus == UserStatus.banned
                    ? null
                    : UserStatus.banned,
              ),
            ),
            const SizedBox(width: 8),
            ...roleFilters.entries.map((e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: e.key,
                isActive: controller.filterRole == e.value,
                activeColor: Colors.white,
                activeBg: AppColors.primary,
                onTap: () => controller.setRoleFilter(e.value),
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.light2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.people_outline,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('No users found',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text('Try a different search or filter',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── USER CARD ─────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final AppUser user;
  const _UserCard({required this.user});

  Color get _roleColor {
    switch (user.role) {
      case UserRole.donor:     return AppColors.blueText;
      case UserRole.receiver:  return AppColors.amberText;
      case UserRole.volunteer: return AppColors.successText;
      case UserRole.user:      return AppColors.textMuted;
    }
  }

  Color get _roleBg {
    switch (user.role) {
      case UserRole.donor:     return AppColors.blueBg;
      case UserRole.receiver:  return AppColors.amberBg;
      case UserRole.volunteer: return AppColors.successBg;
      case UserRole.user:      return AppColors.light2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<UserAdminViewModel>();
    final isBanned = user.status == UserStatus.banned;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBanned
              ? AppColors.dangerBorder
              : AppColors.light2,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // ── Avatar ───────────────────────────────────────────
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isBanned
                    ? AppColors.dangerBg
                    : AppColors.light1,
                child: Text(user.initials,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isBanned
                          ? AppColors.dangerText
                          : AppColors.successText,
                    )),
              ),
              if (isBanned)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.dangerText,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.block,
                        size: 7, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // ── Info ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(user.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _roleBg,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(user.roleLabel,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _roleColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(user.email,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 10, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text('Joined ${user.joinDate}',
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted)),
                    if (user.totalDonations > 0) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.card_giftcard_outlined,
                          size: 10, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text('${user.totalDonations} donations',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted)),
                    ],
                    if (user.totalRequests > 0) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.inbox_outlined,
                          size: 10, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text('${user.totalRequests} requests',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted)),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── Ban/Unban Button ──────────────────────────────────
          const SizedBox(width: 8),
          Material(
            color: isBanned
                ? AppColors.successBg
                : AppColors.dangerBg,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () =>
                  _confirmAction(context, controller, isBanned),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                child: Column(
                  children: [
                    Icon(
                      isBanned
                          ? Icons.lock_open_outlined
                          : Icons.block_outlined,
                      size: 16,
                      color: isBanned
                          ? AppColors.successText
                          : AppColors.dangerText,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBanned ? 'Unban' : 'Ban',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isBanned
                            ? AppColors.successText
                            : AppColors.dangerText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CONFIRMATION DIALOG ───────────────────────────────────────────────────

  void _confirmAction(BuildContext context,
      UserAdminViewModel controller, bool isBanned) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(isBanned ? 'Unban User?' : 'Ban User?',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text(
          isBanned
              ? '${user.name} will be able to use the platform again.'
              : '${user.name} will be restricted from using the platform.',
          style: const TextStyle(
              fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBanned
                  ? AppColors.primary
                  : AppColors.dangerText,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (isBanned) {
                controller.unbanUser(user.id);
              } else {
                controller.banUser(user.id);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        isBanned
                            ? '${user.name} unbanned successfully'
                            : '${user.name} banned successfully',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Text(isBanned ? 'Unban' : 'Ban',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── FILTER CHIP ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor, activeBg;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? activeBg : AppColors.light2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? activeColor
                  : AppColors.successText,
            )),
      ),
    );
  }
}