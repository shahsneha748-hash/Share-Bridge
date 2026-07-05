class VolunteerModel {
  final String userId;
  final String citizenshipNumber;
  final String citizenshipImage;
  final String selfieImage;
  final String vehicle;
  final String availability;
  final String status; // Pending / Approved / Rejected
  final DateTime submittedAt;

  VolunteerModel({
    required this.userId,
    required this.citizenshipNumber,
    required this.citizenshipImage,
    required this.selfieImage,
    required this.vehicle,
    required this.availability,
    required this.status,
    required this.submittedAt,
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
      submittedAt: DateTime.parse(map['submittedAt']),
    );
  }
}