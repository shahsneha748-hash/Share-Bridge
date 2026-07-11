import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../viewmodel/admin_dashboard_viewmodel.dart';
import 'stats_admin_screen.dart';


class AdminDashboardScreen extends StatelessWidget {
  final void Function(int index)? onNavigateToTab;

  const AdminDashboardScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel()..fetchDashboard(),
      child: _DashboardBody(onNavigateToTab: onNavigateToTab),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final void Function(int index)? onNavigateToTab;

  const _DashboardBody({this.onNavigateToTab});

  void _goToTab(BuildContext context, int index) {
    if (onNavigateToTab != null) {
      onNavigateToTab!(index);
    }
  }

  // Time-based greeting
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDashboardViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: vm.isLoading
                ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary))
                : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context
                  .read<AdminDashboardViewModel>()
                  .fetchDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 2, 14, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('OVERVIEW · TODAY'),
                    _buildStatGrid(context, vm),
                    _sectionLabel('QUICK ACTIONS'),
                    _buildQuickActions(context),
                    _sectionLabel('FLAGGED CONTENT'),
                    _buildFlaggedSection(context, vm),
                    _sectionLabel('DONATIONS BY CATEGORY'),
                    _buildCategoryChart(vm),
                    _sectionLabel('TOP DONORS'),
                    _buildDonorLeaderboard(vm),
                    _sectionLabel('RECENT ACTIVITY'),
                    _buildActivityFeed(vm),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TOP BAR

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 16,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style:
                  const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  // OVERVIEW STAT GRID

  Widget _buildStatGrid(
      BuildContext context, AdminDashboardViewModel vm) {
    return Column(
      children: [
        Row(
          children: [
            _statCard(
              icon: Icons.card_giftcard,
              iconBg: AppColors.successBg,
              iconColor: AppColors.successText,
              value: '${vm.totalDonations}',
              label: 'Total donations',
              sub: '+${vm.donationsToday} today',
              subColor: AppColors.successText,
              onTap: () => _goToTab(context, 2),
            ),
            const SizedBox(width: 10),
            _statCard(
              icon: Icons.people_outline,
              iconBg: AppColors.light2,
              iconColor: AppColors.primary,
              value: '${vm.activeUsers}',
              label: 'Active users',
              sub: '+${vm.newUsersToday} new',
              subColor: AppColors.successText,
              onTap: () => _goToTab(context, 1),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard(
              icon: Icons.inventory_2_outlined,
              iconBg: AppColors.amberBg,
              iconColor: AppColors.amberText,
              value: '${vm.availableDonations}',
              label: 'Available items',
              sub: 'live now',
              subColor: AppColors.textMuted,
              onTap: () => _goToTab(context, 2),
            ),
            const SizedBox(width: 10),
            _statCard(
              icon: Icons.flag_outlined,
              iconBg: AppColors.dangerBg,
              iconColor: AppColors.dangerText,
              value: '${vm.pendingReports}',
              label: 'Pending reports',
              sub: vm.pendingReports > 0 ? 'review now' : 'all clear',
              subColor: vm.pendingReports > 0
                  ? AppColors.dangerText
                  : AppColors.successText,
              onTap: () => _goToTab(context, 3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    required String sub,
    required Color subColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.light2, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(height: 10),
                Text(value,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(sub,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: subColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // QUICK ACTIONS

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _quickAction(
          icon: Icons.bar_chart,
          label: 'Statistics',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const StatsAdminScreen()),
            );
          },
        ),
        const SizedBox(width: 10),
        _quickAction(
          icon: Icons.flag_outlined,
          label: 'Reports',
          onTap: () => _goToTab(context, 3),
        ),
        const SizedBox(width: 10),
        _quickAction(
          icon: Icons.volunteer_activism_outlined,
          label: 'Volunteers',
          onTap: () => _goToTab(context, 4),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.light2, width: 0.5),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(height: 6),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  FLAGGED CONTENT (real pending reports)

  Widget _buildFlaggedSection(
      BuildContext context, AdminDashboardViewModel vm) {
    if (vm.flagged.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.light2, width: 0.5),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: AppColors.successText, size: 20),
            SizedBox(width: 8),
            Text('No pending reports — all clear!',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return Column(
      children: vm.flagged.map((f) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.dangerBorder, width: 0.7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(f.reason,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dangerText)),
                  ),
                  const Spacer(),
                  Text(
                    vm.relativeTime(f.createdAt),
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                f.details.isNotEmpty ? f.details : f.reportType,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textDark),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _goToTab(context, 3),
                  child: const Text('Review in Reports',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  //  CATEGORY CHART (real percentages)

  Widget _buildCategoryChart(AdminDashboardViewModel vm) {
    if (vm.categoryPercents.isEmpty) {
      return _emptyCard('No donations yet');
    }

    final entries = vm.categoryPercents.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        children: entries.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(e.key,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textDark)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.light2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 36,
                  child: Text('${e.value}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successText)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // TOP DONORS (real, aggregated)

  Widget _buildDonorLeaderboard(AdminDashboardViewModel vm) {
    if (vm.topDonors.isEmpty) {
      return _emptyCard('No donor data yet');
    }

    const medals = ['🥇', '🥈', '🥉'];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        children: vm.topDonors.asMap().entries.map((entry) {
          final i = entry.key;
          final donor = entry.value;
          final initials = donor.name
              .trim()
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase();

          return ListTile(
            dense: true,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(medals[i], style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.light1,
                  child: Text(initials,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successText)),
                ),
              ],
            ),
            title: Text(donor.name,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
            trailing: Text('${donor.items} items',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successText)),
          );
        }).toList(),
      ),
    );
  }

  // RECENT ACTIVITY (real events)

  Widget _buildActivityFeed(AdminDashboardViewModel vm) {
    if (vm.activity.isEmpty) {
      return _emptyCard('No recent activity');
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        children: vm.activity.map((a) {
          return ListTile(
            dense: true,
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.light2,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(a.icon, size: 16, color: AppColors.primary),
            ),
            title: Text(a.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textDark)),
            subtitle: Text(
              vm.relativeTime(a.time),
              style: const TextStyle(
                  fontSize: 10.5, color: AppColors.textMuted),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Text(message,
          style:
          const TextStyle(fontSize: 12, color: AppColors.textMuted)),
    );
  }
}