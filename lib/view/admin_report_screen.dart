import 'package:flutter/material.dart';
import 'admin_dashboard_view.dart';

// ── MODEL (inline for now — move to admin_model.dart later) ──────────────────

enum ReportCategory { user, donationPost, volunteer }

enum ReportStatus { pending, reviewed, actionTaken, dismissed }

class AdminReport {
  final String id;
  final String reportedName;
  final String reportedInitial;
  final ReportCategory category;
  final String reason;
  final String details;
  final String submittedBy;
  final bool isAnonymous;
  final String timeAgo;
  ReportStatus status;

  AdminReport({
    required this.id,
    required this.reportedName,
    required this.reportedInitial,
    required this.category,
    required this.reason,
    required this.details,
    required this.submittedBy,
    required this.isAnonymous,
    required this.timeAgo,
    this.status = ReportStatus.pending,
  });

  String get categoryLabel {
    switch (category) {
      case ReportCategory.user:         return 'User';
      case ReportCategory.donationPost: return 'Donation Post';
      case ReportCategory.volunteer:    return 'Volunteer';
    }
  }
}

// ── DUMMY DATA (replace with Firestore later) ─────────────────────────────────

final List<AdminReport> _dummyReports = [
  AdminReport(
    id: '1',
    reportedName: 'Ram Sah',
    reportedInitial: 'R',
    category: ReportCategory.user,
    reason: 'Harassment',
    details: 'This user has been sending threatening messages to multiple donors on the platform.',
    submittedBy: 'Sita Poudel',
    isAnonymous: false,
    timeAgo: '10 min ago',
    status: ReportStatus.pending,
  ),
  AdminReport(
    id: '2',
    reportedName: 'Winter Clothes Drive',
    reportedInitial: 'W',
    category: ReportCategory.donationPost,
    reason: 'Fake listing',
    details: 'The item listed does not exist. The donor is asking for money in exchange.',
    submittedBy: 'Anonymous',
    isAnonymous: true,
    timeAgo: '1 hr ago',
    status: ReportStatus.pending,
  ),
  AdminReport(
    id: '3',
    reportedName: 'Sita Sharma',
    reportedInitial: 'S',
    category: ReportCategory.volunteer,
    reason: 'Spam/Fraud',
    details: 'This volunteer is collecting items but not delivering them to receivers.',
    submittedBy: 'Mohan Rai',
    isAnonymous: false,
    timeAgo: '3 hr ago',
    status: ReportStatus.reviewed,
  ),
  AdminReport(
    id: '4',
    reportedName: 'Old Books Lot',
    reportedInitial: 'O',
    category: ReportCategory.donationPost,
    reason: 'Unsafe Item',
    details: 'Books have mold and could be a health hazard. Should not be donated.',
    submittedBy: 'Anonymous',
    isAnonymous: true,
    timeAgo: '5 hr ago',
    status: ReportStatus.dismissed,
  ),
  AdminReport(
    id: '5',
    reportedName: 'Bikash Thapa',
    reportedInitial: 'B',
    category: ReportCategory.user,
    reason: 'Inappropriate content',
    details: 'User uploaded inappropriate images in their donation post.',
    submittedBy: 'Bina KC',
    isAnonymous: false,
    timeAgo: '1 day ago',
    status: ReportStatus.actionTaken,
  ),
];

// ── MAIN ADMIN REPORT SCREEN ─────────────────────────────────────────────────

class AdminReportScreen extends StatefulWidget {
  const AdminReportScreen({super.key});

  @override
  State<AdminReportScreen> createState() => _AdminReportScreenState();
}

class _AdminReportScreenState extends State<AdminReportScreen> {
  // Filter: null = show all
  ReportStatus? _filterStatus;

  List<AdminReport> get _filteredReports {
    if (_filterStatus == null) return _dummyReports;
    return _dummyReports
        .where((r) => r.status == _filterStatus)
        .toList();
  }

  int get _pendingCount =>
      _dummyReports.where((r) => r.status == ReportStatus.pending).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildTopBar(),
          _buildSummaryRow(),
          _buildFilterRow(),
          Expanded(
            child: _filteredReports.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
              itemCount: _filteredReports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _ReportCard(
                    report: _filteredReports[i],
                    onStatusChanged: () => setState(() {}),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TOP BAR ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
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
            child: Text('Reports',
                style: TextStyle(color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          // Pending badge
          if (_pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEBEB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$_pendingCount pending',
                  style: const TextStyle(
                      color: Color(0xFFA32D2D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  // ── SUMMARY ROW ────────────────────────────────────────────────────────────

  Widget _buildSummaryRow() {
    final counts = {
      'Total':    _dummyReports.length,
      'Pending':  _dummyReports.where((r) => r.status == ReportStatus.pending).length,
      'Reviewed': _dummyReports.where((r) => r.status == ReportStatus.reviewed).length,
      'Resolved': _dummyReports.where((r) =>
      r.status == ReportStatus.actionTaken ||
          r.status == ReportStatus.dismissed).length,
    };

    final colors = {
      'Total':    AppColors.primary,
      'Pending':  AppColors.dangerText,
      'Reviewed': AppColors.amberText,
      'Resolved': AppColors.successText,
    };

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Row(
        children: counts.entries.map((e) {
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
                          fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── FILTER ROW ─────────────────────────────────────────────────────────────

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
            final isActive = _filterStatus == e.value;
            return GestureDetector(
              onTap: () => setState(() => _filterStatus = e.value),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.light2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(e.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : AppColors.successText,
                    )),
              ),
            );
          }).toList(),
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
            child: const Icon(Icons.shield_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text('No reports here',
              style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 6),
          const Text('All clear in this category!',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── REPORT CARD ───────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final AdminReport report;
  final VoidCallback onStatusChanged;

  const _ReportCard({
    required this.report,
    required this.onStatusChanged,
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

          // ── CARD HEADER ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                // Avatar
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
                                  fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(width: 6),
                          const Text('·',
                              style: TextStyle(color: AppColors.textMuted)),
                          const SizedBox(width: 6),
                          Text(report.timeAgo,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
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

          // ── REPORT DETAILS ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reason chip
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.dangerBorder, width: 0.5),
                      ),
                      child: Text(report.reason,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.dangerText,
                          )),
                    ),
                    const Spacer(),
                    // Reporter
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

                // Details text
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

          // ── ACTION BUTTONS (only show if pending or reviewed) ─────────────
          if (report.status == ReportStatus.pending ||
              report.status == ReportStatus.reviewed) ...[
            const Divider(height: 1, color: Color(0xFFEDF2E7)),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Mark as reviewed
                  if (report.status == ReportStatus.pending)
                    Expanded(
                      child: _ActionButton(
                        label: 'Mark reviewed',
                        icon: Icons.remove_red_eye_outlined,
                        bg: AppColors.amberBg,
                        fg: AppColors.amberText,
                        onTap: () {
                          report.status = ReportStatus.reviewed;
                          onStatusChanged();
                        },
                      ),
                    ),
                  if (report.status == ReportStatus.pending)
                    const SizedBox(width: 8),

                  // Take action
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

                  // Dismiss
                  Expanded(
                    child: _ActionButton(
                      label: 'Dismiss',
                      icon: Icons.close,
                      bg: const Color(0xFFF1EFE8),
                      fg: AppColors.textMuted,
                      onTap: () {
                        report.status = ReportStatus.dismissed;
                        onStatusChanged();
                      },
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

  // ── ACTION DIALOG ──────────────────────────────────────────────────────────

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
              // Handle
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
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text('Reported: ${report.reportedName}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 16),

              // Action options
              _DialogAction(
                icon: Icons.person_off_outlined,
                iconBg: AppColors.dangerBg,
                iconColor: AppColors.dangerText,
                title: 'Ban user',
                subtitle: 'Permanently restrict this account',
                onTap: () {
                  Navigator.pop(ctx);
                  report.status = ReportStatus.actionTaken;
                  _showConfirmation(context, 'User banned successfully');
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
                  report.status = ReportStatus.actionTaken;
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
                  report.status = ReportStatus.actionTaken;
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

  // ── SUCCESS CONFIRMATION ───────────────────────────────────────────────────

  void _showConfirmation(BuildContext context, String message) {
    onStatusChanged();
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
                style: const TextStyle(color: Colors.white, fontSize: 13)),
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
                  style: TextStyle(fontSize: 10,
                      fontWeight: FontWeight.w500, color: fg)),
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
    required this.icon,    required this.iconBg,
    required this.iconColor, required this.title,
    required this.subtitle, required this.onTap,
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
                            fontSize: 11, color: AppColors.textMuted)),
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