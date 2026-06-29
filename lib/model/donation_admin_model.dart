import 'package:cloud_firestore/cloud_firestore.dart';

enum DonationCategory { food, clothes, stationery, others }
enum DonationStatus { available, taken }

class AdminDonation {
  final String id;
  final String title;
  final String donorName;
  final String donorInitials;
  final DonationCategory category;
  DonationStatus status;
  final String location;
  final String postedTime;

  AdminDonation({
    required this.id,
    required this.title,
    required this.donorName,
    required this.donorInitials,
    required this.category,
    required this.status,
    required this.location,
    required this.postedTime,
  });

  String get categoryLabel {
    switch (category) {
      case DonationCategory.food:       return 'Food';
      case DonationCategory.clothes:    return 'Clothes';
      case DonationCategory.stationery: return 'Stationery';
      case DonationCategory.others:     return 'Others';
    }
  }

  String get statusLabel {
    switch (status) {
      case DonationStatus.available: return 'Available';
      case DonationStatus.taken:     return 'Taken';
    }
  }

  static DonationCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':       return DonationCategory.food;
      case 'clothes':    return DonationCategory.clothes;
      case 'stationery': return DonationCategory.stationery;
      default:           return DonationCategory.others;
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
    if (diff.inHours < 24)   return '${diff.inHours} hr ago';
    return '${diff.inDays} day ago';
  }

  factory AdminDonation.fromMap(Map<String, dynamic> map) {
    final itemName = map['itemName'] as String? ?? 'Unknown';
    final donorId  = map['userId']   as String? ?? '';
    return AdminDonation(
      id:            map['id']       as String? ?? '',
      title:         itemName,
      donorName: map['donorName'] as String? ?? 'Unknown',
      donorInitials: itemName.isNotEmpty ? itemName[0].toUpperCase() : '?',
      category:      _parseCategory(map['category'] as String? ?? ''),
      status:        (map['isDonated'] as bool? ?? false)
          ? DonationStatus.taken
          : DonationStatus.available,
      location:      map['location']  as String? ?? '',
      postedTime:    _timeAgo(map['createdAt']),
    );
  }
}