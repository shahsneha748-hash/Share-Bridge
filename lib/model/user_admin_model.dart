enum UserRole { donor, receiver, volunteer }
enum UserStatus { active, banned }

class AppUser {
  final String id;
  final String name;
  final String initials;
  final UserRole role;
  UserStatus status;
  final String joinDate;
  final int totalDonations;
  final int totalRequests;
  final String email;

  AppUser({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.status,
    required this.joinDate,
    required this.totalDonations,
    required this.totalRequests,
    required this.email,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.donor:     return 'Donor';
      case UserRole.receiver:  return 'Receiver';
      case UserRole.volunteer: return 'Volunteer';
    }
  }
}