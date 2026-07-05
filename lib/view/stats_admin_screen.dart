import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/stats_viewmodel.dart';
import 'admin_dashboard_view.dart';
import '../constants/colors.dart';

class StatsAdminScreen extends StatelessWidget {
  const StatsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatsViewModel()..fetchStats(),
      child: const _StatsBody(),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatsViewModel>();

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
              onRefresh: () =>
                  context.read<StatsViewModel>().fetchStats(),
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('👥 Users Overview'),
                    const SizedBox(height: 12),
                    _buildUsersBarChart(vm),
                    const SizedBox(height: 20),
                    _buildSectionTitle('👤 Users by Role'),
                    const SizedBox(height: 12),
                    _buildRolePieChart(vm),
                    const SizedBox(height: 20),
                    _buildSectionTitle('🚩 Reports Overview'),
                    const SizedBox(height: 12),
                    _buildReportsBarChart(vm),
                    const SizedBox(height: 20),
                    _buildSectionTitle('📋 Reports by Type'),
                    const SizedBox(height: 12),
                    _buildReportTypePieChart(vm),
                    const SizedBox(height: 20),
                    _buildSectionTitle('📦 Donations Overview'),
                    const SizedBox(height: 12),
                    _buildComingSoon(
                        'Waiting for teammate to complete donations data'),
                    const SizedBox(height: 20),
                    _buildSectionTitle('🙋 Volunteers Overview'),
                    const SizedBox(height: 12),
                    _buildComingSoon(
                        'Waiting for teammate to complete volunteers data'),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 4,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left,
                color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Statistics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),
    );
  }

  // ── USERS BAR CHART ────────────────────────────────────────────────────────

  Widget _buildUsersBarChart(StatsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(color: AppColors.primary, label: 'Total'),
              _LegendItem(color: AppColors.successText, label: 'Active'),
              _LegendItem(color: AppColors.dangerText, label: 'Banned'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (vm.totalUsers + 2).toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0: return const Text('Total', style: TextStyle(fontSize: 10));
                          case 1: return const Text('Active', style: TextStyle(fontSize: 10));
                          case 2: return const Text('Banned', style: TextStyle(fontSize: 10));
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.light2,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        toY: vm.totalUsers.toDouble(),
                        color: AppColors.primary,
                        width: 32,
                        borderRadius: BorderRadius.circular(6)),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: vm.activeUsers.toDouble(),
                        color: AppColors.successText,
                        width: 32,
                        borderRadius: BorderRadius.circular(6)),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: vm.bannedUsers.toDouble(),
                        color: AppColors.dangerText,
                        width: 32,
                        borderRadius: BorderRadius.circular(6)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── ROLE PIE CHART ─────────────────────────────────────────────────────────

  Widget _buildRolePieChart(StatsViewModel vm) {
    final total = vm.donorCount + vm.receiverCount +
        vm.volunteerCount + (vm.totalUsers - vm.donorCount -
        vm.receiverCount - vm.volunteerCount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: total == 0
                ? const Center(
                child: Text('No role data yet',
                    style: TextStyle(color: AppColors.textMuted)))
                : PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: vm.donorCount.toDouble() == 0
                        ? 0.001
                        : vm.donorCount.toDouble(),
                    color: AppColors.blueText,
                    title: 'Donors\n${vm.donorCount}',
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 10, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: vm.receiverCount.toDouble() == 0
                        ? 0.001
                        : vm.receiverCount.toDouble(),
                    color: AppColors.amberText,
                    title: 'Receivers\n${vm.receiverCount}',
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 10, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: vm.volunteerCount.toDouble() == 0
                        ? 0.001
                        : vm.volunteerCount.toDouble(),
                    color: AppColors.successText,
                    title: 'Volunteers\n${vm.volunteerCount}',
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 10, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: (vm.totalUsers - vm.donorCount -
                        vm.receiverCount - vm.volunteerCount)
                        .toDouble() == 0
                        ? 0.001
                        : (vm.totalUsers - vm.donorCount -
                        vm.receiverCount - vm.volunteerCount)
                        .toDouble(),
                    color: AppColors.textMuted,
                    title: 'Users\n${vm.totalUsers - vm.donorCount - vm.receiverCount - vm.volunteerCount}',
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(color: AppColors.blueText, label: 'Donors'),
              _LegendItem(color: AppColors.amberText, label: 'Receivers'),
              _LegendItem(color: AppColors.successText, label: 'Volunteers'),
              _LegendItem(color: AppColors.textMuted, label: 'Users'),
            ],
          ),
        ],
      ),
    );
  }

  // ── REPORTS BAR CHART ──────────────────────────────────────────────────────

  Widget _buildReportsBarChart(StatsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(color: AppColors.primary, label: 'Total'),
              _LegendItem(color: AppColors.dangerText, label: 'Pending'),
              _LegendItem(color: AppColors.successText, label: 'Resolved'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (vm.totalReports + 2).toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0: return const Text('Total', style: TextStyle(fontSize: 10));
                          case 1: return const Text('Pending', style: TextStyle(fontSize: 10));
                          case 2: return const Text('Resolved', style: TextStyle(fontSize: 10));
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.light2,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                        toY: vm.totalReports.toDouble(),
                        color: AppColors.primary,
                        width: 32,
                        borderRadius: BorderRadius.circular(6)),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: vm.pendingReports.toDouble(),
                        color: AppColors.dangerText,
                        width: 32,
                        borderRadius: BorderRadius.circular(6)),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: vm.resolvedReports.toDouble(),
                        color: AppColors.successText,
                        width: 32,
                        borderRadius: BorderRadius.circular(6)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── REPORT TYPE PIE CHART ──────────────────────────────────────────────────

  Widget _buildReportTypePieChart(StatsViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: vm.totalReports == 0
                ? const Center(
                child: Text('No report data yet',
                    style: TextStyle(color: AppColors.textMuted)))
                : PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: vm.userReports.toDouble() == 0
                        ? 0.001
                        : vm.userReports.toDouble(),
                    color: AppColors.blueText,
                    title: 'User\n${vm.userReports}',
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 10, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: vm.donationReports.toDouble() == 0
                        ? 0.001
                        : vm.donationReports.toDouble(),
                    color: AppColors.amberText,
                    title: 'Donation\n${vm.donationReports}',
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 10, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: vm.volunteerReports.toDouble() == 0
                        ? 0.001
                        : vm.volunteerReports.toDouble(),
                    color: AppColors.successText,
                    title: 'Volunteer\n${vm.volunteerReports}',
                    radius: 60,
                    titleStyle: const TextStyle(
                        fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(color: AppColors.blueText, label: 'User'),
              _LegendItem(color: AppColors.amberText, label: 'Donation'),
              _LegendItem(color: AppColors.successText, label: 'Volunteer'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.hourglass_empty,
              color: AppColors.textMuted, size: 32),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}