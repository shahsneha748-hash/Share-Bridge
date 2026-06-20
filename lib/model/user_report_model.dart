import 'package:flutter/material.dart';

class ReportType {
  final String label;
  final IconData icon;
  final String name;
  final String initial;
  final String subtitle;
  final int stars;

  ReportType({
    required this.label,
    required this.icon,
    required this.name,
    required this.initial,
    required this.subtitle,
    required this.stars,
  });
}

class UserReportModel {
  static List<ReportType> reportTypes = [
    ReportType(
      label: 'A User',
      icon: Icons.person_outline,
      name: 'Ram Sah',
      initial: 'R',
      subtitle: '4.8 · Donor · Member since 2026',
      stars: 4,
    ),
    ReportType(
      label: 'A Donation Post',
      icon: Icons.list_alt_outlined,
      name: 'Winter Clothes Drive',
      initial: 'W',
      subtitle: 'Clothing · Posted 2 days ago',
      stars: 0,
    ),
    ReportType(
      label: 'A Volunteer',
      icon: Icons.volunteer_activism_outlined,
      name: 'Sita Sharma',
      initial: 'S',
      subtitle: '4.5 · Volunteer · Active since 2025',
      stars: 4,
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