class VolunteerTaskModel {
  final String id;
  final String title;
  final String pickupLocation;
  final String dropoffLocation;
  final bool needsVolunteer;
  final String status;
  final String? volunteerId;

  VolunteerTaskModel({
    required this.id,
    required this.title,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.needsVolunteer,
    required this.status,
    this.volunteerId,
  });

  factory VolunteerTaskModel.fromJson(
      Map<String, dynamic> json,
      String id,
      ) {
    return VolunteerTaskModel(
      id: id,
      title: json['title'] ?? '',
      pickupLocation: json['pickupLocation'] ?? '',
      dropoffLocation: json['dropoffLocation'] ?? '',
      needsVolunteer: json['needsVolunteer'] ?? false,
      status: json['status'] ?? '',
      volunteerId: json['volunteerId'],
    );
  }
}