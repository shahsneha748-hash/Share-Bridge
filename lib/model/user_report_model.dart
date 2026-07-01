import 'package:flutter/material.dart';

class ReportType {
  final String label;
  final IconData icon;

  ReportType({
    required this.label,
    required this.icon,
  });
}

class UserReportModel {
  static List<ReportType> reportTypes = [
    ReportType(
      label: 'A User',
      icon: Icons.person_outline,
    ),
    ReportType(
      label: 'A Donation Post',
      icon: Icons.list_alt_outlined,
    ),
    ReportType(
      label: 'A Volunteer',
      icon: Icons.volunteer_activism_outlined,
    ),
  ];

  static List<String> reasons = [
    'Fake listing',
    'Unsafe Item',
    'Harassment',
    'Spam/Fraud',
    'Inappropriate content',
    'Other',
  ];
}