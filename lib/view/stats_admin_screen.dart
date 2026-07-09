import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/stats_viewmodel.dart';
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
                    _buildDonationsChart(vm),
                    const SizedBox(height: 20),
                    _buildSectionTitle('🙋 Volunteers Overview'),
                    const SizedBox(height: 12),
                    _buildVolunteersChart(vm),
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

  /// Helper: builds a pie section that HIDES its label when value is 0
  /// (prevents overlapping cramped text for empty slices)
  PieChartSectionData _pieSection({
    required int value,
    required Color color,
    required String label,
  }) {
    final isEmpty = value == 0;
    return PieChartSectionData(
      value: isEmpty ? 0.001 : value.toDouble(),
      color: color,
      showTitle: !isEmpty,
      title: '$label\n$value',
      radius: 60,
      titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
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
                          case 0:
                            return const Text('Total',
                                style: TextStyle(fontSize: 10));
                          case 1:
                            return const Text('Active',
                                style: TextStyle(fontSize: 10));
                          case 2:
                            return const Text('Banned',
                                style: TextStyle(fontSize: 10));
                          default:
                            return const Text('');
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

  // ── USERS BY ROLE PIE CHART ────────────────────────────────────────────────

  Widget _buildRolePieChart(StatsViewModel vm) {
    final plainUsers = vm.totalUsers -
        vm.donorCount -
        vm.receiverCount -
        vm.volunteerCount;
    final total = vm.totalUsers;

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
                  _pieSection(
                      value: vm.donorCount,
                      color: AppColors.blueText,
                      label: 'Donors'),
                  _pieSection(
                      value: vm.receiverCount,
                      color: AppColors.amberText,
                      label: 'Receivers'),
                  _pieSection(
                      value: vm.volunteerCount,
                      color: AppColors.successText,
                      label: 'Volunteers'),
                  _pieSection(
                      value: plainUsers,
                      color: AppColors.textMuted,
                      label: 'Users'),
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
              _LegendItem(
                  color: AppColors.successText, label: 'Volunteers'),
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
                          case 0:
                            return const Text('Total',
                                style: TextStyle(fontSize: 10));
                          case 1:
                            return const Text('Pending',
                                style: TextStyle(fontSize: 10));
                          case 2:
                            return const Text('Resolved',
                                style: TextStyle(fontSize: 10));
                          default:
                            return const Text('');
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
                  _pieSection(
                      value: vm.userReports,
                      color: AppColors.blueText,
                      label: 'User'),
                  _pieSection(
                      value: vm.donationReports,
                      color: AppColors.amberText,
                      label: 'Donation'),
                  _pieSection(
                      value: vm.volunteerReports,
                      color: AppColors.successText,
                      label: 'Volunteer'),
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
              _LegendItem(
                  color: AppColors.successText, label: 'Volunteer'),
            ],
          ),
        ],
      ),
    );
  }

  // ── DONATIONS CHART ────────────────────────────────────────────────────────

  Widget _buildDonationsChart(StatsViewModel vm) {
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
            child: vm.totalDonations == 0
                ? const Center(
                child: Text('No donation data yet',
                    style: TextStyle(color: AppColors.textMuted)))
                : PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  _pieSection(
                      value: vm.foodDonations,
                      color: AppColors.successText,
                      label: 'Food'),
                  _pieSection(
                      value: vm.clothesDonations,
                      color: AppColors.blueText,
                      label: 'Clothes'),
                  _pieSection(
                      value: vm.stationeryDonations,
                      color: AppColors.amberText,
                      label: 'Stationery'),
                  _pieSection(
                      value: vm.othersDonations,
                      color: AppColors.textMuted,
                      label: 'Others'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(color: AppColors.successText, label: 'Food'),
              _LegendItem(color: AppColors.blueText, label: 'Clothes'),
              _LegendItem(color: AppColors.amberText, label: 'Stationery'),
              _LegendItem(color: AppColors.textMuted, label: 'Others'),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MiniStat(
                  label: 'Available',
                  value: vm.availableDonations,
                  color: AppColors.successText),
              _MiniStat(
                  label: 'Taken',
                  value: vm.takenDonations,
                  color: AppColors.primary),
              _MiniStat(
                  label: 'Total',
                  value: vm.totalDonations,
                  color: AppColors.textDark),
            ],
          ),
        ],
      ),
    );
  }

  // ── VOLUNTEERS CHART ───────────────────────────────────────────────────────

  Widget _buildVolunteersChart(StatsViewModel vm) {
    final totalVol = vm.pendingVolunteers +
        vm.approvedVolunteers +
        vm.rejectedVolunteers;

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
              _LegendItem(color: AppColors.amberText, label: 'Pending'),
              _LegendItem(color: AppColors.successText, label: 'Approved'),
              _LegendItem(color: AppColors.dangerText, label: 'Rejected'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: totalVol == 0
                ? const Center(
                child: Text('No volunteer data yet',
                    style: TextStyle(color: AppColors.textMuted)))
                : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalVol + 2).toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Pending',
                                style: TextStyle(fontSize: 10));
                          case 1:
                            return const Text('Approved',
                                style: TextStyle(fontSize: 10));
                          case 2:
                            return const Text('Rejected',
                                style: TextStyle(fontSize: 10));
                          default:
                            return const Text('');
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
                        toY: vm.pendingVolunteers.toDouble(),
                        color: AppColors.amberText,
                        width: 32,
                        borderRadius: BorderRadius.circular(6)),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                        toY: vm.approvedVolunteers.toDouble(),
                        color: AppColors.successText,
                        width: 32,
                        borderRadius: BorderRadius.circular(6)),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(
                        toY: vm.rejectedVolunteers.toDouble(),
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

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}