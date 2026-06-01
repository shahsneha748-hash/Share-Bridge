import 'dart:io';

class ReportType {
  final String label;
  final String name;
  final String initial;
  final String subtitle;
  final int stars;

  ReportType({
    required this.label,
    required this.name,
    required this.initial,
    required this.subtitle,
    required this.stars,
  });
}

class ReportSubmission {
  final String selectedType;
  final String selectedReason;
  final String details;
  final bool isAnonymous;
  final File? attachedImage;

  ReportSubmission({
    required this.selectedType,
    required this.selectedReason,
    required this.details,
    required this.isAnonymous,
    this.attachedImage,
  });
}

// All static data lives here — not in the view
final List<ReportType> reportTypes = [
  ReportType(
    label: 'A User',
    name: 'Ram Sah',
    initial: 'R',
    subtitle: '4.8 · Donor · Member since 2026',
    stars: 4,
  ),
  ReportType(
    label: 'A Donation Post',
    name: 'Winter Clothes Drive',
    initial: 'W',
    subtitle: 'Clothing · Posted 2 days ago',
    stars: 0,
  ),
  ReportType(
    label: 'A Volunteer',
    name: 'Sita Sharma',
    initial: 'S',
    subtitle: '4.5 · Volunteer · Active since 2025',
    stars: 4,
  ),
];

final List<String> reportReasons = [
  'Fake listing',
  'Unsafe Item',
  'Harassment',
  'Spam/Fraud',
  'Inappropriate content',
  'Other',
];