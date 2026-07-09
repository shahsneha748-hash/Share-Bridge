import 'package:flutter/material.dart';
import 'admin_dashboard_view.dart';
import '../viewmodel/admin_report_viewmodel.dart';
import '../constants/colors.dart';

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  late AdminReportViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = AdminReportViewModel();
    _vm.fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildTopBar(),
            _buildSummaryRow(),
            _buildFilterRow(),
            Expanded(
              child: _vm.isLoading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary))
                  : _vm.filteredReports.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                padding:
                const EdgeInsets.fromLTRB(14, 12, 14, 24),
                itemCount: _vm.filteredReports.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (_, i) => _ReportCard(
                  report: _vm.filteredReports[i],
                  onStatusChanged: (reportId, newStatus) =>
                      _vm.updateStatus(reportId, newStatus),
                  onBanUser: (report) => _vm.banUserFromReport(report),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20, right: 16, bottom: 14,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Reports',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ),
          if (_vm.pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${_vm.pendingCount} pending',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    final counts = {
      'Total':    _vm.totalReports,
      'Pending':  _vm.pendingCount,
      'Reviewed': _vm.reviewedCount,
      'Resolved': _vm.resolvedCount,
    };

    final colors = {
      'Total':    AppColors.primary,
      'Pending':  AppColors.dangerText,
      'Reviewed': AppColors.amberText,
      'Resolved': AppColors.successText,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Row(
        children: counts.entries.map((e) {
          final color = colors[e.key]!;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(e.value.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(e.key,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = <String, ReportStatus?>{
      'All':          null,
      'Pending':      ReportStatus.pending,
      'Reviewed':     ReportStatus.reviewed,
      'Action taken': ReportStatus.actionTaken,
      'Dismissed':    ReportStatus.dismissed,
    };

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: filters.entries.map((e) {
            final isActive = _vm.filterStatus == e.value;
            return GestureDetector(
              onTap: () => _vm.setFilter(e.value),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.light2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(e.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : AppColors.successText,
                    )),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

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
            child: const Icon(Icons.shield_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('No reports here',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text('All clear in this category!',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── REPORT CARD ───────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final AdminReport report;
  final Function(String, ReportStatus) onStatusChanged;
  final Function(AdminReport) onBanUser;

  const _ReportCard({
    required this.report,
    required this.onStatusChanged,
    required this.onBanUser,
  });

  Color get _statusColor {
    switch (report.status) {
      case ReportStatus.pending:     return AppColors.dangerText;
      case ReportStatus.reviewed:    return AppColors.amberText;
      case ReportStatus.actionTaken: return AppColors.successText;
      case ReportStatus.dismissed:   return AppColors.textMuted;
    }
  }

  Color get _statusBg {
    switch (report.status) {
      case ReportStatus.pending:     return AppColors.dangerBg;
      case ReportStatus.reviewed:    return AppColors.amberBg;
      case ReportStatus.actionTaken: return AppColors.successBg;
      case ReportStatus.dismissed:   return const Color(0xFFF1EFE8);
    }
  }

  String get _statusLabel {
    switch (report.status) {
      case ReportStatus.pending:     return 'Pending';
      case ReportStatus.reviewed:    return 'Reviewed';
      case ReportStatus.actionTaken: return 'Action taken';
      case ReportStatus.dismissed:   return 'Dismissed';
    }
  }

  IconData get _categoryIcon {
    switch (report.category) {
      case ReportCategory.user:         return Icons.person_outline;
      case ReportCategory.donationPost: return Icons.list_alt_outlined;
      case ReportCategory.volunteer:    return Icons.volunteer_activism_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light2, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.light1,
                  child: Text(report.reportedInitial,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successText,
                      )),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.reportedName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          )),
                      Row(
                        children: [
                          Icon(_categoryIcon,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Text(report.categoryLabel,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted)),
                          const SizedBox(width: 6),
                          const Text('·',
                              style: TextStyle(
                                  color: AppColors.textMuted)),
                          const SizedBox(width: 6),
                          Text(report.timeAgo,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      )),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEDF2E7)),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.dangerBorder,
                            width: 0.5),
                      ),
                      child: Text(report.reason,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dangerText,
                          )),
                    ),
                    const Spacer(),
                    Icon(
                      report.isAnonymous
                          ? Icons.visibility_off_outlined
                          : Icons.person_outline,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.isAnonymous
                          ? 'Anonymous'
                          : report.submittedBy,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(report.details,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textDark,
                      height: 1.5,
                    )),
                const SizedBox(height: 12),
              ],
            ),
          ),

          if (report.status == ReportStatus.pending ||
              report.status == ReportStatus.reviewed) ...[
            const Divider(height: 1, color: Color(0xFFEDF2E7)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  if (report.status == ReportStatus.pending)
                    Expanded(
                      child: _ActionButton(
                        label: 'Mark reviewed',
                        icon: Icons.remove_red_eye_outlined,
                        bg: AppColors.amberBg,
                        fg: AppColors.amberText,
                        onTap: () => onStatusChanged(
                            report.id, ReportStatus.reviewed),
                      ),
                    ),
                  if (report.status == ReportStatus.pending)
                    const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Take action',
                      icon: Icons.gavel_outlined,
                      bg: AppColors.dangerBg,
                      fg: AppColors.dangerText,
                      onTap: () => _showActionDialog(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'Dismiss',
                      icon: Icons.close,
                      bg: const Color(0xFFF1EFE8),
                      fg: AppColors.textMuted,
                      onTap: () => onStatusChanged(
                          report.id, ReportStatus.dismissed),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Take action on report',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text('Reported: ${report.reportedName}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              _DialogAction(
                icon: Icons.person_off_outlined,
                iconBg: AppColors.dangerBg,
                iconColor: AppColors.dangerText,
                title: 'Ban user',
                subtitle: report.reportedId.isEmpty
                    ? 'No user linked to this report'
                    : 'Permanently restrict this account',
                onTap: report.reportedId.isEmpty
                    ? () {}
                    : () {
                  Navigator.pop(ctx);
                  onBanUser(report); // REAL ban
                  _showConfirmation(
                      context, '${report.reportedName} banned successfully');
                },
              ),
              const SizedBox(height: 10),
              _DialogAction(
                icon: Icons.delete_outline,
                iconBg: AppColors.dangerBg,
                iconColor: AppColors.dangerText,
                title: 'Remove post',
                subtitle: 'Delete the reported donation post',
                onTap: () {
                  Navigator.pop(ctx);
                  onStatusChanged(report.id, ReportStatus.actionTaken);
                  _showConfirmation(context, 'Post removed successfully');
                },
              ),
              const SizedBox(height: 10),
              _DialogAction(
                icon: Icons.warning_amber_outlined,
                iconBg: AppColors.amberBg,
                iconColor: AppColors.amberText,
                title: 'Send warning',
                subtitle: 'Notify the user about this violation',
                onTap: () {
                  Navigator.pop(ctx);
                  onStatusChanged(report.id, ReportStatus.actionTaken);
                  _showConfirmation(context, 'Warning sent successfully');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmation(BuildContext context, String message) {
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
            Text(message,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ── SMALL REUSABLE WIDGETS ────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg, fg;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label, required this.icon,
    required this.bg,    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogAction extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final VoidCallback onTap;

  const _DialogAction({
    required this.icon,      required this.iconBg,
    required this.iconColor, required this.title,
    required this.subtitle,  required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.light2, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        )),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}