import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { donor, receiver, volunteer, user }
enum UserStatus { active, banned }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  UserStatus status;
  final String joinDate;
  final int totalDonations;
  final int totalRequests;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinDate,
    required this.totalDonations,
    required this.totalRequests,
  });

  // computed — no need to store it
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  String get roleLabel {
    switch (role) {
      case UserRole.donor:     return 'Donor';
      case UserRole.receiver:  return 'Receiver';
      case UserRole.volunteer: return 'Volunteer';
      case UserRole.user:      return 'User';
    }
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // role
    UserRole role;
    switch ((data['role'] as String? ?? '').toLowerCase()) {
      case 'donor':     role = UserRole.donor;     break;
      case 'receiver':  role = UserRole.receiver;  break;
      case 'volunteer': role = UserRole.volunteer; break;
      default:          role = UserRole.user;
    }

    // isBanned
    final isBanned = data['isBanned'] as bool? ?? false;

    // joinDate from createdAt timestamp
    String joinDate = '—';
    final raw = data['createdAt'];
    if (raw is Timestamp) {
      final dt = raw.toDate();
      const months = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      joinDate = '${months[dt.month - 1]} ${dt.year}';
    }

    return AppUser(
      id:             doc.id,
      name:           data['fullName']       as String? ?? '',
      email:          data['email']          as String? ?? '',
      role:           role,
      status:         isBanned ? UserStatus.banned : UserStatus.active,
      joinDate:       joinDate,
      totalDonations: data['totalDonations'] as int? ?? 0,
      totalRequests:  data['totalRequests']  as int? ?? 0,
    );
  }
}