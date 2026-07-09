import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../repo/admin_report_repo.dart';
import '../repo/admin_report_repo_impl.dart';

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
  final String reportedId;
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
    required this.reportedId,
    this.status = ReportStatus.pending,
  });

  String get categoryLabel {
    switch (category) {
      case ReportCategory.user:
        return 'User';
      case ReportCategory.donationPost:
        return 'Donation Post';
      case ReportCategory.volunteer:
        return 'Volunteer';
    }
  }

  static ReportCategory _parseCategory(String type) {
    switch (type.toLowerCase()) {
      case 'a donation post':
        return ReportCategory.donationPost;
      case 'a volunteer':
        return ReportCategory.volunteer;
      default:
        return ReportCategory.user;
    }
  }

  static ReportStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'reviewed':
        return ReportStatus.reviewed;
      case 'actiontaken':
        return ReportStatus.actionTaken;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }

  static String _timeAgo(dynamic createdAt) {
    if (createdAt == null) return '';
    DateTime dt;
    if (createdAt is Timestamp) {
      dt = createdAt.toDate();
    } else {
      return '';
    }
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day ago';
  }

  factory AdminReport.fromMap(Map<String, dynamic> map) {
    final name = map['reportedName'] as String? ?? 'Unknown';
    return AdminReport(
      id: map['id'] as String? ?? '',
      reportedName: name,
      reportedInitial: name.isNotEmpty ? name[0].toUpperCase() : '?',
      category: _parseCategory(map['reportType'] as String? ?? ''),
      reason: map['reason'] as String? ?? '',
      details: map['details'] as String? ?? '',
      submittedBy: map['reporterName'] as String? ?? 'Anonymous',
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      timeAgo: _timeAgo(map['createdAt']),
      reportedId: map['reportedId'] as String? ?? '',
      status: _parseStatus(map['status'] as String? ?? 'pending'),
    );
  }
}

class AdminReportViewModel extends ChangeNotifier {
  final AdminReportRepo _repo = AdminReportRepoImpl();

  List<AdminReport> _allReports = [];
  bool isLoading = false;
  ReportStatus? filterStatus;

  List<AdminReport> get filteredReports {
    if (filterStatus == null) return _allReports;
    return _allReports.where((r) => r.status == filterStatus).toList();
  }

  int get totalReports => _allReports.length;
  int get pendingCount =>
      _allReports.where((r) => r.status == ReportStatus.pending).length;
  int get reviewedCount =>
      _allReports.where((r) => r.status == ReportStatus.reviewed).length;
  int get resolvedCount => _allReports
      .where((r) =>
  r.status == ReportStatus.actionTaken ||
      r.status == ReportStatus.dismissed)
      .length;

  Future<void> fetchReports() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await _repo.fetchReports();
      _allReports = data.map(AdminReport.fromMap).toList();
    } catch (e) {
      debugPrint('Error fetching reports: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  void setFilter(ReportStatus? status) {
    filterStatus = status;
    notifyListeners();
  }

  Future<void> updateStatus(String reportId, ReportStatus newStatus) async {
    try {
      final statusStr = newStatus.name;
      await _repo.updateReportStatus(reportId, statusStr);
      final index = _allReports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _allReports[index].status = newStatus;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
    }
  }

  /// Ban the reported user directly from the report, then mark actionTaken
  Future<void> banUserFromReport(AdminReport report) async {
    try {
      await _repo.banReportedUser(report.reportedId, report.id);
      final index = _allReports.indexWhere((r) => r.id == report.id);
      if (index != -1) {
        _allReports[index].status = ReportStatus.actionTaken;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error banning user from report: $e');
    }
  }
}
