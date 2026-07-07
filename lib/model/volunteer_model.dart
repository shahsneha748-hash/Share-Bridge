class VolunteerModel {
  final String userId;
  final String citizenshipNumber;
  final String citizenshipImage;
  final String selfieImage;
  final String vehicle;
  final String availability;
  final String status; // Pending / Approved / Rejected
  final DateTime submittedAt;


  // --- new fields, all backward-compatible with old docs ---
  final String fullName;
  final bool isAcceptingTasks; // the "pause / go offline" toggle
  final double rating;
  final int completedTasksCount;
  final int activeTaskCount;


  VolunteerModel({
    required this.userId,
    required this.citizenshipNumber,
    required this.citizenshipImage,
    required this.selfieImage,
    required this.vehicle,
    required this.availability,
    required this.status,
    required this.submittedAt,

    this.fullName = '',
    this.isAcceptingTasks = true,
    this.rating = 0.0,
    this.completedTasksCount = 0,
    this.activeTaskCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'citizenshipNumber': citizenshipNumber,
      'citizenshipImage': citizenshipImage,
      'selfieImage': selfieImage,
      'vehicle': vehicle,
      'availability': availability,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),

      'fullName': fullName,
      'isAcceptingTasks': isAcceptingTasks,
      'rating': rating,
      'completedTasksCount': completedTasksCount,
      'activeTaskCount': activeTaskCount,
    };
  }

  factory VolunteerModel.fromMap(Map<String, dynamic> map) {
    return VolunteerModel(
      userId: map['userId'],
      citizenshipNumber: map['citizenshipNumber'],
      citizenshipImage: map['citizenshipImage'],
      selfieImage: map['selfieImage'],
      vehicle: map['vehicle'],
      availability: map['availability'],
      status: map['status'],
      submittedAt: map['submittedAt'] != null
          ? DateTime.parse(map['submittedAt'])
          : DateTime.now(),
      // old docs won't have these - default them instead of crashing
      fullName: map['fullName'] ?? '',
      isAcceptingTasks: map['isAcceptingTasks'] ?? true,
      rating: (map['rating'] ?? 0.0).toDouble(),
      completedTasksCount: map['completedTasksCount'] ?? 0,
      activeTaskCount: map['activeTaskCount'] ?? 0,
    );
  }
}